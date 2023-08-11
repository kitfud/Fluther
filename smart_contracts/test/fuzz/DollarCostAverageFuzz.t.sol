// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title DollarCostAverage smart contract fuzz (stateless) test
 */

import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";
import {DeployMocks} from "../../script/DeployMocks.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AutomationLayer} from "../../src/AutomationLayer.sol";
import {IDEXRouter} from "../../src/interfaces/IDEXRouter.sol";
import {Security} from "../../src/Security.sol";
import {DollarCostAverage, IDollarCostAverage} from "../../src/DollarCostAverage.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DollarCostAverageFuzz is Test {
    /* solhint-disable */
    Deploy deployer;
    HelperConfig config;
    AutomationLayer automation;
    DollarCostAverage dca;
    address token1;
    address token2;
    address defaultRouter;
    address wrapNative;
    address signer;
    address duhToken;
    ERC20Mock anotherToken;

    address public user = makeAddr("user");
    address public PAYMENT_INTERFACE = makeAddr("userInterface");

    uint256 public constant INITAL_DEX_ERC20_FUNDS = 100 ether;
    uint256 public constant INITAL_USER_ERC20_FUNDS = 100 ether;
    uint256 public constant INITAL_USER_FUNDS = 100 ether;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        deployer = new Deploy();
        deployer.run();

        automation = deployer.automation();
        dca = deployer.dca();
        config = deployer.config();
        defaultRouter = deployer.defaultRouter();

        (address wNative, , , , , , , , uint256 deployerPk) = config
            .activeNetworkConfig();
        wrapNative = wNative;
        signer = vm.addr(deployerPk);
        duhToken = address(deployer.duh());
        anotherToken = new ERC20Mock();

        vm.deal(user, INITAL_USER_FUNDS);
        if (block.chainid == 11155111) {
            vm.prank(user);
            wrapNative.call{value: 50 ether}("");

            DeployMocks mocksDeployer = new DeployMocks();
            mocksDeployer.run();
            token1 = deployer.token1() == address(0)
                ? address(mocksDeployer.weth())
                : deployer.token1();
            token2 = deployer.token2() == address(0)
                ? address(mocksDeployer.uni())
                : deployer.token2();

            vm.prank(signer);
            ERC20Mock(duhToken).mint(user, 50 ether);

            vm.startPrank(user);
            anotherToken.mint(user, 10 ether);
            anotherToken.approve(defaultRouter, type(uint256).max);
            ERC20Mock(wrapNative).approve(defaultRouter, type(uint256).max);
            ERC20Mock(wrapNative).approve(address(dca), type(uint256).max);
            ERC20Mock(duhToken).approve(defaultRouter, type(uint256).max);
            IDEXRouter(defaultRouter).addLiquidity(
                address(anotherToken),
                wrapNative,
                10 ether,
                10 ether,
                1,
                1,
                user,
                block.timestamp
            );
            IDEXRouter(defaultRouter).addLiquidity(
                duhToken,
                wrapNative,
                10 ether,
                10 ether,
                1,
                1,
                user,
                block.timestamp
            );
            vm.stopPrank();
        } else {
            token1 = deployer.token1();
            token2 = deployer.token2();

            ERC20Mock(wNative).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
            ERC20Mock(wNative).mint(user, INITAL_USER_ERC20_FUNDS);
        }

        ERC20Mock(token1).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token2).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token1).mint(user, INITAL_USER_ERC20_FUNDS);

        vm.startPrank(signer);
        dca.setAllowedERC20s(token1, true);
        dca.setAllowedERC20s(token2, true);
        dca.setAllowedERC20s(wrapNative, true);
        dca.setAllowedERC20s(address(anotherToken), true);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: createRecurringBuy
    /// -----------------------------------------------------------------------

    function testCreateRecurringBuySuccessWhenNotPaused(
        uint256 amountToSpend,
        address tokenToSpend,
        address tokenToBuy,
        uint256 timeIntervalInSeconds,
        address paymentInterface
    ) public {
        vm.assume(amountToSpend > 0);
        vm.assume(tokenToSpend != address(0));
        vm.assume(tokenToBuy != address(0));
        vm.assume(tokenToBuy != tokenToSpend);
        timeIntervalInSeconds = bound(timeIntervalInSeconds, 1, 365 days);

        vm.startPrank(signer);
        dca.setAllowedERC20s(tokenToSpend, true);
        dca.setAllowedERC20s(tokenToBuy, true);
        vm.stopPrank();

        vm.prank(msg.sender);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            defaultRouter
        );

        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );
        uint256[] memory ids = dca.getSenderToIds(msg.sender);

        assertEq(buy.sender, msg.sender);
        assertEq(buy.amountToSpend, amountToSpend);
        assertEq(buy.tokenToSpend, tokenToSpend);
        assertEq(buy.tokenToBuy, tokenToBuy);
        assertEq(buy.timeIntervalInSeconds, timeIntervalInSeconds);
        assertEq(buy.paymentInterface, paymentInterface);
        assertEq(buy.dexRouter, defaultRouter);
        assertEq(buy.paymentDue, block.timestamp);
        assertEq(buy.accountNumber, accountNumber);
        assertEq(uint8(buy.status), uint8(IDollarCostAverage.Status.SET));
        assertEq(ids.length, 2);
        assertEq(ids[0], 0);
        assertEq(ids[1], currRecurringBuyId);
    }

    function testCreateRecurringBuyRevertsIfContractPaused(
        uint256 amountToSpend,
        address tokenToSpend,
        address tokenToBuy,
        uint256 timeIntervalInSeconds,
        address paymentInterface,
        address dexRouter
    ) public {
        vm.assume(amountToSpend > 0);
        vm.assume(tokenToSpend != address(0));
        vm.assume(tokenToBuy != address(0));
        vm.assume(timeIntervalInSeconds > 0);

        vm.prank(signer);
        dca.pause();

        vm.prank(msg.sender);
        vm.expectRevert("Pausable: paused");
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAutomationLayer
    /// -----------------------------------------------------------------------

    function testSetAutomationLayerSuccessWhenNotPaused(
        address automationLayerAddress
    ) public {
        vm.assume(automationLayerAddress != address(0));

        address automationLayerBefore = address(dca.getAutomationLayer());

        vm.prank(signer);
        dca.setAutomationLayer(automationLayerAddress);

        address automationLayerAfter = address(dca.getAutomationLayer());

        assertEq(automationLayerBefore, address(automation));
        assertEq(automationLayerAfter, automationLayerAddress);
    }

    function testSetAutomationLayerRevertsIfCallerNotAllowed(
        address automationLayerAddress
    ) public {
        vm.assume(automationLayerAddress != address(0));
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setAutomationLayer(automationLayerAddress);
    }

    function testSetAutomationLayerRevertsIfContractPaused(
        address automationLayerAddress
    ) public {
        vm.assume(automationLayerAddress != address(0));

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setAutomationLayer(automationLayerAddress);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setDefaultRouter
    /// -----------------------------------------------------------------------

    function testSetDefaultRouterSuccess(address defRouter) public {
        vm.assume(defRouter != address(0));

        address defaultRouterBefore = dca.getDefaultRouter();

        vm.prank(signer);
        dca.setDefaultRouter(defRouter);

        address defaultRouterAfter = dca.getDefaultRouter();

        assertEq(defaultRouterBefore, defaultRouter);
        assertEq(defaultRouterAfter, defRouter);
    }

    function testSetDefaultRouterRevertsIfCallerNotAllowed(
        address defRouter
    ) public {
        vm.assume(defRouter != address(0));
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setDefaultRouter(defRouter);
    }

    function testSetDefaultRouterRevertsIfContractPaused(
        address defRouter
    ) public {
        vm.assume(defRouter != address(0));

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setDefaultRouter(defRouter);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAcceptingNewRecurringBuys
    /// -----------------------------------------------------------------------

    function testSetAcceptingNewRecurringBuysSuccess(
        bool acceptingNewRecurringBuys
    ) public {
        bool acceptingNewRecurringBuysBefore = dca
            .getAcceptingNewRecurringBuys();

        vm.prank(signer);
        dca.setAcceptingNewRecurringBuys(acceptingNewRecurringBuys);

        bool acceptingNewRecurringBuysAfter = dca
            .getAcceptingNewRecurringBuys();

        assertEq(acceptingNewRecurringBuysBefore, true);
        assertEq(acceptingNewRecurringBuysAfter, acceptingNewRecurringBuys);
    }

    function testSetAcceptingNewRecurringBuysRevertsIfCallerNotAllowed(
        bool acceptingNewRecurringBuys
    ) public {
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setAcceptingNewRecurringBuys(acceptingNewRecurringBuys);
    }

    function testSetAcceptingNewRecurringBuysRevertsIfContractPaused(
        bool acceptingNewRecurringBuys
    ) public {
        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setAcceptingNewRecurringBuys(acceptingNewRecurringBuys);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setFee
    /// -----------------------------------------------------------------------

    function testSetFeeSuccess(uint256 fee) public {
        uint256 feeBefore = dca.getFee();

        vm.prank(signer);
        dca.setFee(fee);

        uint256 feeAfter = dca.getFee();

        assertEq(feeBefore, 100);
        assertEq(feeAfter, fee);
    }

    function testSetFeeRevertsIfCallerNotAllowed(uint256 fee) public {
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setFee(fee);
    }

    function testSetFeeRevertsIfContractPaused(uint256 fee) public {
        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setFee(fee);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setContractFeeShare
    /// -----------------------------------------------------------------------

    function testSetContractFeeShareSuccess(uint256 contractFeeShare) public {
        uint256 contractFeeShareBefore = dca.getContractFeeShare();

        vm.prank(signer);
        dca.setContractFeeShare(contractFeeShare);

        uint256 contractFeeShareAfter = dca.getContractFeeShare();

        assertEq(contractFeeShareBefore, 5000);
        assertEq(contractFeeShareAfter, contractFeeShare);
    }

    function testSetContractFeeRevertsIfCallerNotAllowed(
        uint256 contractFeeShare
    ) public {
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setContractFeeShare(contractFeeShare);
    }

    function testSetContractFeeRevertsIfContractPaused(
        uint256 contractFeeShare
    ) public {
        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setContractFeeShare(contractFeeShare);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setSlippagePercentage
    /// -----------------------------------------------------------------------

    function testSetSlippagePercentageSuccess(
        uint256 slippagePercentage
    ) public {
        uint256 slippagePercentageBefore = dca.getSlippagePercentage();

        vm.prank(signer);
        dca.setSlippagePercentage(slippagePercentage);

        uint256 slippagePercentageAfter = dca.getSlippagePercentage();

        assertEq(slippagePercentageBefore, 100);
        assertEq(slippagePercentageAfter, slippagePercentage);
    }

    function testSetSlippagePercentageRevertsIfCallerNotAllowed(
        uint256 slippagePercentage
    ) public {
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setSlippagePercentage(slippagePercentage);
    }

    function testSetSlippagePercentageRevertsIfContractPaused(
        uint256 slippagePercentage
    ) public {
        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setSlippagePercentage(slippagePercentage);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setDuh
    /// -----------------------------------------------------------------------

    function testSetDuhSuccess(address duh) public {
        vm.assume(duh != address(0));

        address duhBefore = dca.getDuh();

        vm.prank(signer);
        dca.setDuh(duh);

        address duhAfter = dca.getDuh();

        assertEq(duhBefore, address(duhToken));
        assertEq(duhAfter, duh);
    }

    function testSetDuhRevertsIfCallerNotAllowed(address duh) public {
        vm.assume(duh != address(0));
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setDuh(duh);
    }

    function testSetDuhRevertsIfContractPaused(address duh) public {
        vm.assume(duh != address(0));

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setDuh(duh);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAllowedERC20s
    /// -----------------------------------------------------------------------

    function testSetAllowedERC20sSuccess(address token, bool isAllowed) public {
        vm.assume(token != address(0));

        vm.prank(signer);
        dca.setAllowedERC20s(token, isAllowed);

        bool allowedAfter = dca.getAllowedERC20s(token);

        assertEq(allowedAfter, isAllowed);
    }

    function testSetAllowedERC20sRevertsIfCallerNotAllowed(
        address token,
        bool isAllowed
    ) public {
        vm.assume(token != address(0));
        vm.assume(msg.sender != signer);

        vm.prank(msg.sender);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setAllowedERC20s(token, isAllowed);
    }

    function testSetAllowedERC20sRevertsIfContractPaused(
        address token,
        bool isAllowed
    ) public {
        vm.assume(token != address(0));

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setAllowedERC20s(token, isAllowed);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAllowedERC20s
    /// -----------------------------------------------------------------------

    function testGetAllowedERC20s(address token) public view {
        dca.getAllowedERC20s(token);
    }

    /// -----------------------------------------------------------------------
    /// Test for: checkTrigger
    /// -----------------------------------------------------------------------

    function testCheckTrigger(uint256 recurringBuyId) public view {
        dca.checkTrigger(recurringBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: isRecurringBuyValid
    /// -----------------------------------------------------------------------

    function testIsRecurringBuyValid(uint256 recurringBuyId) public view {
        dca.isRecurringBuyValid(recurringBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: prospectAutomationPayment
    /// -----------------------------------------------------------------------

    function testProspectAutomationPayment(uint256 recurringBuyId) public view {
        dca.prospectAutomationPayment(recurringBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getRangeOfRecurringBuys
    /// -----------------------------------------------------------------------

    modifier createRecurringBuy() {
        vm.prank(msg.sender);
        dca.createRecurringBuy(
            1 ether,
            token1,
            token2,
            2 minutes,
            address(0),
            defaultRouter
        );
        _;
    }

    function testGetRangeOfRecurringBuysSuccess(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        endRecBuyId = bound(endRecBuyId, 1, dca.getNextRecurringBuyId() - 1);
        startRecBuyId = bound(startRecBuyId, 1, endRecBuyId);

        dca.getRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetRangeOfRecurringBuysRevertsPath1(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(endRecBuyId != 0);
        vm.assume(startRecBuyId > endRecBuyId);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetRangeOfRecurringBuysRevertsPath2(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(startRecBuyId != 0);
        vm.assume(endRecBuyId >= dca.getNextRecurringBuyId());

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetRangeOfRecurringBuysRevertsPath3(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(startRecBuyId == 0);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetRangeOfRecurringBuysRevertsPath4(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(endRecBuyId == 0);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getValidRangeOfRecurringBuys
    /// -----------------------------------------------------------------------

    function testGetValidRangeOfRecurringBuysSuccess(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        endRecBuyId = bound(endRecBuyId, 1, dca.getNextRecurringBuyId() - 1);
        startRecBuyId = bound(startRecBuyId, 1, endRecBuyId);

        dca.getValidRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetValidRangeOfRecurringBuysRevertsPath1(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(endRecBuyId != 0);
        vm.assume(startRecBuyId > endRecBuyId);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getValidRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetValidRangeOfRecurringBuysRevertsPath2(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(startRecBuyId != 0);
        vm.assume(endRecBuyId >= dca.getNextRecurringBuyId());

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getValidRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetValidRangeOfRecurringBuysRevertsPath3(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(startRecBuyId == 0);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getValidRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    function testGetValidRangeOfRecurringBuysRevertsPath4(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        vm.assume(endRecBuyId == 0);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getValidRangeOfRecurringBuys(startRecBuyId, endRecBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getRecurringBuysFromUser
    /// -----------------------------------------------------------------------

    function testGetRecurringBuysFromUser(
        address sender
    )
        public
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
        createRecurringBuy
    {
        dca.getRecurringBuysFromUser(sender);
    }
}
