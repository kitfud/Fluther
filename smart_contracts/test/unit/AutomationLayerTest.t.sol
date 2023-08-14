// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title AutomationLayer smart contract unit test
 */

import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";
import {DeployMocks} from "../../script/DeployMocks.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AutomationLayer, IAutomationLayer} from "../../src/AutomationLayer.sol";
import {DollarCostAverage} from "../../src/DollarCostAverage.sol";
import {NodeSequencer, INodeSequencer} from "../../src/NodeSequencer.sol";
import {Duh} from "../../src/Duh.sol";
import {Security} from "../../src/Security.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract AutomationLayerTest is Test {
    /* solhint-disable */
    Deploy deployer;
    HelperConfig config;
    AutomationLayer automation;
    DollarCostAverage dca;
    NodeSequencer sequencer;
    address token1;
    address token2;
    Duh duhToken;
    address signer;
    uint256 minimumDuh;
    uint256 automationFee;
    address oracle;
    address defaultRouter;

    address public user = makeAddr("user");
    address public PAYMENT_INTERFACE = makeAddr("userInterface");

    uint256 public constant INITAL_DEX_ERC20_FUNDS = 100 ether;
    uint256 public constant INITAL_USER_ERC20_FUNDS = 100 ether;
    uint256 public constant INITAL_USER_FUNDS = 100 ether;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Events to test
    /// -----------------------------------------------------------------------

    event AccountCreated(
        address indexed user,
        address indexed automatedContract,
        uint256 id
    );

    event AccountCancelled(
        uint256 indexed accountNumber,
        address indexed user,
        address indexed automatedContract
    );

    event AutomationDone(
        uint256 indexed accountNumber,
        address indexed user,
        address indexed automatedContract
    );

    event Withdrawn(address indexed to, uint256 amount);

    event SequencerAddressSet(
        address indexed caller,
        address indexed sequencer
    );

    event OracleAddressSet(address indexed caller, address indexed oracle);

    event AutomationFeeSet(address indexed caller, uint256 automationFee);

    event AcceptingAccountsSet(
        address indexed caller,
        bool acceptingNewAccounts
    );

    event NodeSet(
        address indexed caller,
        address indexed node,
        bool isNodeRegistered
    );

    event DuhTokenSet(address indexed caller, address indexed duh);

    event MinimumDuhSet(address indexed caller, uint256 minimumDuh);

    event BatchAutomationDone(
        address indexed node,
        uint256[] accountNumbers,
        bool[] success
    );

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        deployer = new Deploy();
        deployer.run();

        automation = deployer.automation();
        dca = deployer.dca();
        config = deployer.config();
        sequencer = deployer.sequencer();
        duhToken = deployer.duh();

        (
            address wNative,
            address defaultRouter_,
            address duh,
            uint256 minDuh,
            uint256 automationFee_,
            address oracleAddr,
            ,
            ,
            uint256 deployerPk
        ) = config.activeNetworkConfig();

        minimumDuh = minDuh;
        automationFee = automationFee_;
        oracle = oracleAddr;
        signer = vm.addr(deployerPk);
        defaultRouter = defaultRouter_;
        duhToken = address(duhToken) == address(0) ? Duh(duh) : duhToken;

        vm.deal(user, INITAL_USER_FUNDS);
        if (block.chainid == 11155111) {
            vm.prank(user);
            wNative.call{value: 1 ether}("");

            DeployMocks mocksDeployer = new DeployMocks();
            mocksDeployer.run();
            token1 = deployer.token1() == address(0)
                ? address(mocksDeployer.weth())
                : deployer.token1();
            token2 = deployer.token2() == address(0)
                ? address(mocksDeployer.uni())
                : deployer.token2();
        } else {
            token1 = deployer.token1();
            token2 = deployer.token2();

            ERC20Mock(wNative).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
            ERC20Mock(wNative).mint(user, INITAL_USER_ERC20_FUNDS);

            vm.prank(signer);
            duhToken.mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        }

        ERC20Mock(token1).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token2).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token1).mint(user, INITAL_USER_ERC20_FUNDS);

        vm.startPrank(signer);
        dca.setAllowedERC20s(token1, true);
        dca.setAllowedERC20s(token2, true);
        dca.setAllowedERC20s(wNative, true);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructor() public {
        address duh = automation.getDuh();
        uint256 minimumDuh_ = automation.getMinimumDuh();
        address sequencerAddress = automation.getSequencerAddress();
        uint256 automationFee_ = automation.getAutomationFee();
        address oracleAddress = automation.getOracleAddress();
        bool acceptingNewAccounts = automation.getAcceptingNewAccounts();

        assertEq(duh, address(duhToken));
        assertEq(minimumDuh_, minimumDuh);
        assertEq(sequencerAddress, address(sequencer));
        assertEq(automationFee_, automationFee);
        assertEq(oracleAddress, oracle);
        assertEq(acceptingNewAccounts, true);
    }

    /// -----------------------------------------------------------------------
    /// Test for: createAccount
    /// -----------------------------------------------------------------------

    function testCreateAccountSuccess() public {
        uint256 id = 0;

        vm.prank(user);
        automation.createAccount(id, user, address(dca));

        uint256 accountNumber = automation.getNextAccountNumber() - 1;
        IAutomationLayer.Account memory account = automation.getAccount(
            accountNumber
        );

        assertEq(account.user, user);
        assertEq(account.automatedContract, address(dca));
        assertEq(account.id, id);
        assertEq(uint8(account.status), uint8(IAutomationLayer.Status.SET));
    }

    function testCreateAccountEvent() public {
        uint256 id = 0;

        vm.prank(user);
        vm.expectEmit(true, true, false, true, address(automation));
        emit AccountCreated(user, address(dca), 0);
        automation.createAccount(id, user, address(dca));
    }

    function testCreateAccountSuccessRefertsIfNotAcceptingNewAccounts() public {
        uint256 id = 0;

        vm.prank(signer);
        automation.setAcceptingNewAccounts(false);

        vm.prank(user);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__NotAccpetingNewAccounts.selector
        );
        automation.createAccount(id, user, address(dca));
    }

    function testCreateAccountSuccessRefertsIfContractPaused() public {
        uint256 id = 0;

        vm.prank(signer);
        automation.pause();

        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        automation.createAccount(id, user, address(dca));
    }

    function testCreateAccountSuccessRefertsIfUserIsAddress0() public {
        uint256 id = 0;

        vm.prank(user);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__InvalidAddress.selector
        );
        automation.createAccount(id, address(0), address(dca));
    }

    function testCreateAccountSuccessRefertsIfAutomatedContractIsAddress0()
        public
    {
        uint256 id = 0;

        vm.prank(user);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__InvalidAddress.selector
        );
        automation.createAccount(id, user, address(0));
    }

    /// -----------------------------------------------------------------------
    /// Test for: cancelAccount
    /// -----------------------------------------------------------------------

    modifier createAccount() {
        uint256 id = 0;

        vm.prank(user);
        automation.createAccount(id, user, address(dca));
        _;
    }

    function testCancelAccountSuccess() public createAccount {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(user);
        automation.cancelAccount(accountNumber);

        IAutomationLayer.Account memory account = automation.getAccount(
            accountNumber
        );

        assertEq(
            uint8(account.status),
            uint8(IAutomationLayer.Status.CANCELLED)
        );
    }

    function testCancelAccountEvent() public createAccount {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(user);
        vm.expectEmit(true, true, true, false, address(automation));
        emit AccountCancelled(accountNumber, user, address(dca));
        automation.cancelAccount(accountNumber);
    }

    function testCancelAccountRevertsIfAccountNotSet() public createAccount {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.startPrank(user);
        automation.cancelAccount(accountNumber);

        vm.expectRevert(
            IAutomationLayer.AutomationLayer__InvalidAccountNumber.selector
        );
        automation.cancelAccount(accountNumber);

        vm.expectRevert(
            IAutomationLayer.AutomationLayer__InvalidAccountNumber.selector
        );
        automation.cancelAccount(accountNumber + 1);
        vm.stopPrank();
    }

    function testCancelAccountRevertsIfCallerNotUserOrAutomatedContract()
        public
        createAccount
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(makeAddr("anotherUser"));
        vm.expectRevert(IAutomationLayer.AutomationLayer__NotAllowed.selector);
        automation.cancelAccount(accountNumber);
    }

    function testCancelAccountRevertsIfContractPaused() public createAccount {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(signer);
        automation.pause();

        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        automation.cancelAccount(accountNumber);
    }

    /// -----------------------------------------------------------------------
    /// Test for: triggerAutomation
    /// -----------------------------------------------------------------------

    modifier createRecurringBuy(address caller) {
        vm.startPrank(caller);
        dca.createRecurringBuy(
            1 ether,
            token1,
            token2,
            2 minutes,
            address(0),
            defaultRouter
        );
        ERC20Mock(token1).approve(address(dca), type(uint256).max);
        vm.stopPrank();
        _;
    }

    modifier giveDuhToken(address caller) {
        vm.startPrank(signer);
        duhToken.mint(caller, 1 ether);
        duhToken.mint(user, 1 ether);
        vm.stopPrank();

        vm.prank(caller);
        duhToken.approve(address(automation), type(uint256).max);

        vm.prank(user);
        duhToken.approve(address(automation), type(uint256).max);
        _;
    }

    modifier setNode(address caller) {
        vm.prank(caller, caller);
        sequencer.registerNode();
        vm.roll(block.number + 1);
        _;
    }

    modifier setSequencerAddress(address sequencer_) {
        vm.prank(signer);
        automation.setSequencerAddress(sequencer_);
        _;
    }

    function testTriggerAutomationSuccess()
        public
        createRecurringBuy(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        address anotherUser = makeAddr("anotherUser");
        uint256 accountNumber = automation.getNextAccountNumber() - 1;
        uint256 id = automation.getAccount(accountNumber).id;

        // sequencer != address(0)
        uint256 userBalanceBefore = duhToken.balanceOf(anotherUser);

        vm.prank(anotherUser);
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, id));
        automation.triggerAutomation(accountNumber);

        uint256 userBalanceAfter = duhToken.balanceOf(anotherUser);

        assertTrue(userBalanceAfter > userBalanceBefore);

        // sequencer == address(0)
        vm.warp(block.timestamp + 2.1 minutes);

        vm.startPrank(signer);
        automation.setSequencerAddress(address(0));
        duhToken.mint(anotherUser, 1 ether);
        vm.stopPrank();

        uint256 anotherUserBalanceBefore = duhToken.balanceOf(anotherUser);

        vm.startPrank(anotherUser);
        ERC20Mock(token1).mint(anotherUser, 1 ether);
        ERC20Mock(token1).approve(address(dca), type(uint256).max);
        duhToken.approve(address(automation), type(uint256).max);
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, id));
        automation.triggerAutomation(accountNumber);
        vm.stopPrank();

        uint256 anotherUserBalanceAfter = duhToken.balanceOf(anotherUser);

        assertTrue(anotherUserBalanceAfter > anotherUserBalanceBefore);
    }

    function testTriggerAutomationEvent()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        setNode(user)
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        // sequencer != address(0)
        vm.prank(user);
        vm.expectEmit(true, true, true, false, address(automation));
        emit AutomationDone(accountNumber, user, address(dca));
        automation.triggerAutomation(accountNumber);
    }

    function testTriggerAutomationShouldTakeNextBlocksIfCurrentBlockIsLastBlock()
        public
        createRecurringBuy(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        address anotherUser = makeAddr("anotherUser");
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        uint256 endBlockNumber = sequencer.getNode(anotherUser).endBlockNumber;
        vm.roll(endBlockNumber);

        vm.prank(anotherUser);
        vm.expectCall(
            address(sequencer),
            abi.encodeCall(sequencer.getNode, anotherUser)
        );
        vm.expectCall(
            address(sequencer),
            abi.encodeWithSignature(
                "takeNextBlockNumbers(address)",
                anotherUser
            )
        );
        automation.triggerAutomation(accountNumber);
    }

    function testTriggerAutomationRevertsIfCallerDoesNotHaveEnoughDuhToken()
        public
        createRecurringBuy(user)
        setSequencerAddress(address(0))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(user);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__NotEnoughtTokens.selector
        );
        automation.triggerAutomation(accountNumber);
    }

    function testTriggerAutomationRevertsIfCallerNotCurrentNode()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        setNode(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(makeAddr("anotherUser"));
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__OriginNotNode.selector
        );
        automation.triggerAutomation(accountNumber);
    }

    function testTriggerAutomationRevertsIfContractPaused()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        setNode(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        vm.prank(signer);
        automation.pause();

        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        automation.triggerAutomation(accountNumber);
    }

    /// -----------------------------------------------------------------------
    /// Test for: triggerBatchAutomation
    /// -----------------------------------------------------------------------

    function testTriggerBatchAutomationSuccess()
        public
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        uint256[] memory ids = new uint256[](4);
        ids[0] = automation.getAccount(accountNumbers[0]).id;
        ids[1] = automation.getAccount(accountNumbers[1]).id;
        ids[2] = automation.getAccount(accountNumbers[2]).id;
        ids[3] = automation.getAccount(accountNumbers[3]).id;

        address anotherUser = makeAddr("anotherUser");

        uint256 userBalanceBefore = duhToken.balanceOf(user);
        uint256 anotherUserBalanceBefore = duhToken.balanceOf(anotherUser);

        vm.prank(anotherUser);
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[0]));
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[1]));
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[2]));
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[3]));
        automation.triggerBatchAutomation(accountNumbers);

        uint256 userBalanceAfter = duhToken.balanceOf(user);
        uint256 anotherUserBalanceAfter = duhToken.balanceOf(anotherUser);

        assertEq(userBalanceAfter, userBalanceBefore);
        assertTrue(anotherUserBalanceAfter > anotherUserBalanceBefore);
    }

    function testTriggerBatchAutomationEvent()
        public
        createRecurringBuy(user)
        createRecurringBuy(makeAddr("thirdUser"))
        createRecurringBuy(user)
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        uint256[] memory ids = new uint256[](4);
        ids[0] = automation.getAccount(accountNumbers[0]).id;
        ids[1] = automation.getAccount(accountNumbers[1]).id;
        ids[2] = automation.getAccount(accountNumbers[2]).id;
        ids[3] = automation.getAccount(accountNumbers[3]).id;

        bool[] memory result = new bool[](4);
        result[0] = true;
        result[1] = false;
        result[2] = true;
        result[3] = true;

        address anotherUser = makeAddr("anotherUser");

        vm.prank(anotherUser);
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[0]));
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[2]));
        vm.expectCall(address(dca), abi.encodeCall(dca.trigger, ids[3]));
        vm.expectEmit(true, false, false, true, address(automation));
        emit BatchAutomationDone(anotherUser, accountNumbers, result);
        automation.triggerBatchAutomation(accountNumbers);
    }

    function testTriggerBatchAutomationShouldTakeNextBlocksIfCurrentBlockIsLastBlock()
        public
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        uint256[] memory ids = new uint256[](4);
        ids[0] = automation.getAccount(accountNumbers[0]).id;
        ids[1] = automation.getAccount(accountNumbers[1]).id;
        ids[2] = automation.getAccount(accountNumbers[2]).id;
        ids[3] = automation.getAccount(accountNumbers[3]).id;
        address anotherUser = makeAddr("anotherUser");

        uint256 endBlockNumber = sequencer.getNode(anotherUser).endBlockNumber;
        vm.roll(endBlockNumber);

        vm.prank(anotherUser);
        vm.expectCall(
            address(sequencer),
            abi.encodeCall(sequencer.getNode, anotherUser)
        );
        vm.expectCall(
            address(sequencer),
            abi.encodeWithSignature(
                "takeNextBlockNumbers(address)",
                anotherUser
            )
        );
        automation.triggerBatchAutomation(accountNumbers);
    }

    function testTriggerBatchAutomationRevertsIfCallerDoesNotHaveEnoughDuhToken()
        public
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        setSequencerAddress(address(0))
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        vm.prank(user);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__NotEnoughtTokens.selector
        );
        automation.triggerBatchAutomation(accountNumbers);
    }

    function testTriggerBatchAutomationRevertsIfCallerNotCurrentNode()
        public
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        vm.prank(user);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__OriginNotNode.selector
        );
        automation.triggerBatchAutomation(accountNumbers);
    }

    function testTriggerBatchAutomationRevertsIfContractPaused()
        public
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        vm.prank(signer);
        automation.pause();

        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        automation.triggerBatchAutomation(accountNumbers);
    }

    /// -----------------------------------------------------------------------
    /// Test for: withdraw
    /// -----------------------------------------------------------------------

    function testWithdrawSuccess() public {}

    function testWithdrawEvent() public {
        uint256 amount = 1 ether;

        vm.prank(signer);
        vm.expectEmit(true, false, false, true, address(automation));
        emit Withdrawn(signer, amount);
        automation.withdraw(amount);
    }

    function testWithdrawRevertsIfCallerNotAllowed() public {
        uint256 amount = 1 ether;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.withdraw(amount);
    }

    function testWithdrawRevertsIfContractPaused() public {
        uint256 amount = 1 ether;

        vm.startPrank(signer);
        automation.pause();
        vm.expectRevert("Pausable: paused");
        automation.withdraw(amount);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setDuh
    /// -----------------------------------------------------------------------

    function testSetDuhSuccess() public {
        address newDuh = makeAddr("newDuh");

        address duhBefore = automation.getDuh();

        vm.prank(signer);
        automation.setDuh(newDuh);

        address duhAfter = automation.getDuh();

        assertEq(duhBefore, address(duhToken));
        assertEq(duhAfter, newDuh);
    }

    function testSetDuhEvent() public {
        address newDuh = makeAddr("newDuh");

        vm.prank(signer);
        vm.expectEmit(true, true, false, false, address(automation));
        emit DuhTokenSet(signer, newDuh);
        automation.setDuh(newDuh);
    }

    function testSetDuhRevertsIfNewAddressIsAddress0() public {
        address newDuh = address(0);

        vm.prank(signer);
        vm.expectRevert(
            IAutomationLayer.AutomationLayer__InvalidAddress.selector
        );
        automation.setDuh(newDuh);
    }

    function testSetDuhRevertsIfCallerNotAllowed() public {
        address newDuh = makeAddr("newDuh");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.setDuh(newDuh);
    }

    function testSetDuhRevertsIfContractPaused() public {
        address newDuh = makeAddr("newDuh");

        vm.startPrank(signer);
        automation.pause();
        vm.expectRevert("Pausable: paused");
        automation.setDuh(newDuh);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setMinimumDuh
    /// -----------------------------------------------------------------------

    function testSetMinimumDuhSuccess() public {
        uint256 newMinimumDuh = 100;

        uint256 minimumDuhBefore = automation.getMinimumDuh();

        vm.prank(signer);
        automation.setMinimumDuh(newMinimumDuh);

        uint256 minimumDuhAfter = automation.getMinimumDuh();

        assertEq(minimumDuhBefore, minimumDuh);
        assertEq(minimumDuhAfter, newMinimumDuh);
    }

    function testSetMinimumDuhEvent() public {
        uint256 newMinimumDuh = 100;

        vm.prank(signer);
        vm.expectEmit(true, false, false, true, address(automation));
        emit MinimumDuhSet(signer, newMinimumDuh);
        automation.setMinimumDuh(newMinimumDuh);
    }

    function testSetMinimumDuhRevertsIfCallerNotAllowed() public {
        uint256 newMinimumDuh = 100;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.setMinimumDuh(newMinimumDuh);
    }

    function testSetMinimumDuhRevertsIfContractPaused() public {
        uint256 newMinimumDuh = 100;

        vm.startPrank(signer);
        automation.pause();
        vm.expectRevert("Pausable: paused");
        automation.setMinimumDuh(newMinimumDuh);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setSequencerAddress
    /// -----------------------------------------------------------------------

    function testSetSequencerAddressSuccess() public {
        address newSeq = makeAddr("newSeq");

        address seqBefore = automation.getSequencerAddress();

        vm.prank(signer);
        automation.setSequencerAddress(newSeq);

        address seqAfter = automation.getSequencerAddress();

        assertEq(seqBefore, address(sequencer));
        assertEq(seqAfter, newSeq);
    }

    function testSetSequencerAddressEvent() public {
        address newSeq = makeAddr("newSeq");

        vm.prank(signer);
        vm.expectEmit(true, true, false, false, address(automation));
        emit SequencerAddressSet(signer, newSeq);
        automation.setSequencerAddress(newSeq);
    }

    function testSetSequencerAddressRevertsIfCallerNotAllowed() public {
        address newSeq = makeAddr("newSeq");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.setSequencerAddress(newSeq);
    }

    function testSetSequencerAddressRevertsIfContractPaused() public {
        address newSeq = makeAddr("newSeq");

        vm.startPrank(signer);
        automation.pause();
        vm.expectRevert("Pausable: paused");
        automation.setSequencerAddress(newSeq);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setOracleAddress
    /// -----------------------------------------------------------------------

    function testSetOracleAddressSuccess() public {
        address newOracle = makeAddr("newOracle");

        address oracleBefore = automation.getOracleAddress();

        vm.prank(signer);
        automation.setOracleAddress(newOracle);

        address oracleAfter = automation.getOracleAddress();

        assertEq(oracleBefore, address(0));
        assertEq(oracleAfter, newOracle);
    }

    function testSetOracleAddressEvent() public {
        address newOracle = makeAddr("newOracle");

        vm.prank(signer);
        vm.expectEmit(true, true, false, false, address(automation));
        emit OracleAddressSet(signer, newOracle);
        automation.setOracleAddress(newOracle);
    }

    function testSetOracleAddressRevertsIfCallerNotAllowed() public {
        address newOracle = makeAddr("newOracle");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.setOracleAddress(newOracle);
    }

    function testSetOracleAddressRevertsIfContractPaused() public {
        address newOracle = makeAddr("newOracle");

        vm.startPrank(signer);
        automation.pause();
        vm.expectRevert("Pausable: paused");
        automation.setOracleAddress(newOracle);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAutomationFee
    /// -----------------------------------------------------------------------

    modifier setOracle() {
        address newOracle = makeAddr("newOracle");
        vm.prank(signer);
        automation.setOracleAddress(newOracle);
        _;
    }

    function testSetAutomationFeeSuccess() public setOracle {
        address oracleAddress = automation.getOracleAddress();
        uint256 newAutoFee = 0.1 ether;

        uint256 autoFeeBefore = automation.getAutomationFee();

        vm.prank(signer);
        automation.setAllowed(oracleAddress, true);

        vm.prank(oracleAddress);
        automation.setAutomationFee(newAutoFee);

        uint256 autoFeeAfter = automation.getAutomationFee();

        assertEq(autoFeeBefore, automationFee);
        assertEq(autoFeeAfter, newAutoFee);
    }

    function testSetAutomationFeeEvent() public {
        address oracleAddress = automation.getOracleAddress();
        uint256 newAutoFee = 0.1 ether;

        vm.prank(signer);
        automation.setAllowed(oracleAddress, true);

        vm.prank(oracleAddress);
        vm.expectEmit(true, false, false, true, address(automation));
        emit AutomationFeeSet(oracleAddress, newAutoFee);
        automation.setAutomationFee(newAutoFee);
    }

    function testSetAutomationFeeRevertsIfCallerNotAllowed() public {
        uint256 newAutoFee = 0.1 ether;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.setAutomationFee(newAutoFee);
    }

    function testSetAutomationFeeRevertsIfContractPaused() public {
        address oracleAddress = automation.getOracleAddress();
        uint256 newAutoFee = 0.1 ether;

        vm.prank(signer);
        automation.pause();

        vm.prank(oracleAddress);
        vm.expectRevert("Pausable: paused");
        automation.setAutomationFee(newAutoFee);
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAcceptingNewAccounts
    /// -----------------------------------------------------------------------

    function testSetAcceptingNewAccountsSuccess() public {
        bool newAcc = !automation.getAcceptingNewAccounts();

        bool accBefore = automation.getAcceptingNewAccounts();

        vm.prank(signer);
        automation.setAcceptingNewAccounts(newAcc);

        bool accAfter = automation.getAcceptingNewAccounts();

        assertTrue(accBefore);
        assertTrue(!accAfter);
    }

    function testSetAcceptingNewAccountsEvent() public {
        bool newAcc = !automation.getAcceptingNewAccounts();

        vm.prank(signer);
        vm.expectEmit(true, false, false, true, address(automation));
        emit AcceptingAccountsSet(signer, newAcc);
        automation.setAcceptingNewAccounts(newAcc);
    }

    function testSetAcceptingNewAccountsRevertsIfCallerNotAllowed() public {
        bool newAcc = !automation.getAcceptingNewAccounts();

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        automation.setAcceptingNewAccounts(newAcc);
    }

    function testSetAcceptingNewAccountsRevertsIfContractPaused() public {
        bool newAcc = !automation.getAcceptingNewAccounts();

        vm.startPrank(signer);
        automation.pause();
        vm.expectRevert("Pausable: paused");
        automation.setAcceptingNewAccounts(newAcc);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: checkAutomation
    /// -----------------------------------------------------------------------

    function testCheckAutomationTruePath1()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;
        uint256 recurringBuyId = automation.getAccount(accountNumber).id;
        address anotherUser = makeAddr("anotherUser");

        vm.prank(anotherUser);
        vm.expectCall(
            address(dca),
            abi.encodeCall(dca.checkTrigger, recurringBuyId)
        );
        bool canAutomate = automation.checkAutomation(
            accountNumber,
            anotherUser
        );

        assertTrue(canAutomate);
    }

    function testCheckAutomationTruePath2()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        setSequencerAddress(address(0))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;
        uint256 recurringBuyId = automation.getAccount(accountNumber).id;

        address anotherUser = makeAddr("anotherUser");

        vm.prank(anotherUser);
        vm.expectCall(
            address(dca),
            abi.encodeCall(dca.checkTrigger, recurringBuyId)
        );
        bool canAutomate = automation.checkAutomation(
            accountNumber,
            anotherUser
        );

        assertTrue(canAutomate);
    }

    function testCheckAutomationRevertsIfGivenAccountIsInvalid()
        public
        createRecurringBuy(user)
    {
        uint256 accountNumber = automation.getNextAccountNumber();

        vm.expectRevert(
            IAutomationLayer.AutomationLayer__InvalidAccountNumber.selector
        );
        automation.checkAutomation(accountNumber, user);
    }

    function testCheckAutomationFalseIfNodeIsNotNextNode()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        giveDuhToken(makeAddr("anotherUser"))
        giveDuhToken(makeAddr("thirdUser"))
        setNode(makeAddr("anotherUser"))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        address thirdUser = makeAddr("thirdUser");

        vm.prank(thirdUser);
        bool canAutomate = automation.checkAutomation(accountNumber, thirdUser);

        assertTrue(!canAutomate);
    }

    function testCheckAutomationFalseIfNodeDoesNotHaveMininumDuh()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
        setNode(makeAddr("anotherUser"))
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        address anotherUser = makeAddr("thirdUser");

        vm.prank(anotherUser);
        bool canAutomate = automation.checkAutomation(
            accountNumber,
            anotherUser
        );

        assertTrue(!canAutomate);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAccount
    /// -----------------------------------------------------------------------

    function testGetAccount() public createRecurringBuy(user) {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;
        IAutomationLayer.Account memory account = automation.getAccount(
            accountNumber
        );

        assertEq(account.user, user);
        assertEq(account.automatedContract, address(dca));
        assertEq(account.id, 1);
        assertEq(uint8(account.status), uint8(IAutomationLayer.Status.SET));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getNextAccountNumber
    /// -----------------------------------------------------------------------

    function testGetNextAccountNumber() public {
        uint256 accountNumber = automation.getNextAccountNumber();

        assertEq(accountNumber, 0);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getDuh
    /// -----------------------------------------------------------------------

    function testGetDuh() public {
        address duh = automation.getDuh();

        assertEq(duh, address(duhToken));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getMinimumDuh
    /// -----------------------------------------------------------------------

    function testGetMinimumDuh() public {
        uint256 minDuh = automation.getMinimumDuh();

        assertEq(minDuh, minimumDuh);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getSequencerAddress
    /// -----------------------------------------------------------------------

    function testGetSequencerAddress() public {
        address seq = automation.getSequencerAddress();

        assertEq(seq, address(sequencer));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAutomationFee
    /// -----------------------------------------------------------------------

    function testGetAutomationFee() public {
        uint256 autoFee = automation.getAutomationFee();

        assertEq(autoFee, automationFee);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getOracleAddress
    /// -----------------------------------------------------------------------

    function testGetOracleAddress() public {
        address oracleAddress = automation.getOracleAddress();

        assertEq(oracleAddress, address(0));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAcceptingNewAccounts
    /// -----------------------------------------------------------------------

    function testGetAcceptingNewAccounts() public {
        bool accept = automation.getAcceptingNewAccounts();

        assertTrue(accept);
    }

    /// -----------------------------------------------------------------------
    /// Test for: prospectPayment
    /// -----------------------------------------------------------------------

    function testProspectPayment()
        public
        createRecurringBuy(user)
        giveDuhToken(user)
    {
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        uint256 payment = automation.prospectPayment(accountNumber);

        assertTrue(payment > 0);
    }

    /// -----------------------------------------------------------------------
    /// Test for: prospectPaymentBatch
    /// -----------------------------------------------------------------------

    function testProspectPaymentBatch()
        public
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        createRecurringBuy(user)
        giveDuhToken(user)
    {
        uint256[] memory accountNumbers = new uint256[](4);
        accountNumbers[0] = 0;
        accountNumbers[1] = 1;
        accountNumbers[2] = 2;
        accountNumbers[3] = 3;

        uint256 payment = automation.prospectPaymentBatch(accountNumbers);

        assertTrue(payment > 0);
    }
}
