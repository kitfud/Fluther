// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AutomationLayer, IAutomationLayer} from "../../src/AutomationLayer.sol";
import {DollarCostAverage} from "../../src/DollarCostAverage.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract AutomationLayerTest is Test {
    /* solhint-disable */
    Deploy deployer;
    HelperConfig config;
    AutomationLayer automation;
    DollarCostAverage dca;
    address token1;
    address token2;
    address duhToken;
    address sequencer;
    address signer;
    uint256 minimumDuh;
    uint256 automationFee;
    address oracle;

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

    event TransactionSuccess(
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

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        deployer = new Deploy();
        deployer.run();

        automation = deployer.automation();
        dca = deployer.dca();
        config = deployer.config();
        token1 = deployer.token1();
        token2 = deployer.token2();

        (
            address wNative,
            address defaultRouter,
            address duh,
            uint256 minDuh,
            address sequencerAddr,
            uint256 automationFee_,
            address oracleAddr,
            ,
            ,
            uint256 deployerPk
        ) = config.activeNetworkConfig();
        duhToken = duh;
        minimumDuh = minDuh;
        sequencer = sequencerAddr;
        automationFee = automationFee_;
        oracle = oracleAddr;
        signer = vm.addr(deployerPk);

        ERC20Mock(token1).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token2).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(wNative).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token1).mint(user, INITAL_USER_ERC20_FUNDS);
        ERC20Mock(wNative).mint(user, INITAL_USER_ERC20_FUNDS);

        vm.deal(user, INITAL_USER_FUNDS);
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

        assertEq(duh, duhToken);
        assertEq(minimumDuh_, minimumDuh);
        assertEq(sequencerAddress, sequencer);
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

    /// -----------------------------------------------------------------------
    /// Test for: cancelAccount
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: simpleAutomation
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: withdraw
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: pause
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: unpause
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: setSequencerAddress
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: setOracleAddress
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: setAutomationFee
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: setAcceptingNewAccounts
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: setNode
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: checkSimpleAutomation
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getAccount
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getIsNodeRegistered
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getNextAccountNumber
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getDuh
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getMinimumDuh
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getSequencerAddress
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getAutomationFee
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getOracleAddress
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Test for: getAcceptingNewAccounts
    /// -----------------------------------------------------------------------
}
