// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title DollarCostAverage smart contract unit test
 */

import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";
import {DeployMocks} from "../../script/DeployMocks.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AutomationLayer, IAutomationLayer} from "../../src/AutomationLayer.sol";
import {IDEXRouter} from "../../src/interfaces/IDEXRouter.sol";
import {Security} from "../../src/Security.sol";
import {DollarCostAverage, IDollarCostAverage} from "../../src/DollarCostAverage.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DollarCostAverageTest is Test {
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
    /// Events to test
    /// -----------------------------------------------------------------------

    event RecurringBuyCreated(uint256 indexed recBuyId, address indexed sender);

    event RecurringBuyCancelled(
        uint256 indexed recBuyId,
        address indexed sender
    );

    event PaymentTransferred(
        uint256 indexed recBuyId,
        address indexed sender,
        uint256[] amounts
    );

    event AutomationLayerSet(
        address indexed caller,
        address indexed automationLayerAddress
    );

    event DefaultRouterSet(
        address indexed caller,
        address indexed defaultRouter
    );

    event AcceptingRecurringBuysSet(
        address indexed caller,
        bool acceptingRecurringBuys
    );

    event FeeSet(address indexed caller, uint256 fee);

    event ContractFeeShareSet(address indexed caller, uint256 contractFeeShare);

    event SlippagePercentageSet(
        address indexed caller,
        uint256 slippagePercentage
    );

    event DuhTokenSet(address indexed caller, address indexed duh);

    event ERC20AllowedSet(
        address indexed caller,
        address indexed token,
        bool isAllowed
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
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructorSuccess() public {
        address router = dca.getDefaultRouter();
        address automationLayer = address(dca.getAutomationLayer());
        bool acceptingBuys = dca.getAcceptingNewRecurringBuys();
        address wNative = dca.getWrapNative();

        (, address defaultRouter_, , , , , , , ) = config.activeNetworkConfig();

        assertEq(router, defaultRouter_);
        assertEq(automationLayer, address(automation));
        assertEq(acceptingBuys, true);
        assertEq(wNative, wrapNative);
    }

    function testConstructorRevertsIfDefaultRouterAddressIs0() public {
        address defaultRouter_ = address(0);
        address automationLayer = address(automation);

        vm.startBroadcast(user);
        vm.expectRevert(
            IDollarCostAverage
                .DollarCostAverage__InvalidDefaultRouterAddress
                .selector
        );
        new DollarCostAverage(
            defaultRouter_,
            automationLayer,
            wrapNative,
            duhToken
        );
        vm.stopBroadcast();
    }

    /// -----------------------------------------------------------------------
    /// Test for: createRecurringBuy
    /// -----------------------------------------------------------------------

    function testCreateRecurringBuySuccessAutomationNotZeroAddress() public {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 2 minutes;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;

        vm.prank(user);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );

        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;
        uint256 accountNumber = automation.getNextAccountNumber() - 1;

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );
        uint256[] memory ids = dca.getSenderToIds(user);

        assertEq(buy.sender, user);
        assertEq(buy.amountToSpend, amountToSpend);
        assertEq(buy.tokenToSpend, tokenToSpend);
        assertEq(buy.tokenToBuy, tokenToBuy);
        assertEq(buy.timeIntervalInSeconds, timeIntervalInSeconds);
        assertEq(buy.paymentInterface, paymentInterface);
        assertEq(buy.dexRouter, dexRouter);
        assertEq(buy.paymentDue, block.timestamp);
        assertEq(buy.accountNumber, accountNumber);
        assertEq(uint8(buy.status), uint8(IDollarCostAverage.Status.SET));
        assertEq(ids.length, 2);
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
    }

    function testCreateRecurringBuySuccessAutomationZeroAddress() public {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 2 minutes;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;
        vm.prank(signer);
        dca.setAutomationLayer(address(0));

        vm.prank(user);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );

        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;
        uint256 accountNumber = 0;

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );
        uint256[] memory ids = dca.getSenderToIds(user);

        assertEq(buy.sender, user);
        assertEq(buy.amountToSpend, amountToSpend);
        assertEq(buy.tokenToSpend, tokenToSpend);
        assertEq(buy.tokenToBuy, tokenToBuy);
        assertEq(buy.timeIntervalInSeconds, timeIntervalInSeconds);
        assertEq(buy.paymentInterface, paymentInterface);
        assertEq(buy.dexRouter, dexRouter);
        assertEq(buy.paymentDue, block.timestamp);
        assertEq(buy.accountNumber, accountNumber);
        assertEq(uint8(buy.status), uint8(IDollarCostAverage.Status.SET));
        assertEq(ids.length, 2);
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
    }

    function testCreateRecurringBuyEvent() public {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 2 minutes;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;
        address[] memory path = new address[](2);
        path[0] = tokenToSpend;
        path[1] = tokenToBuy;
        uint256 nextRecurringBuyId = dca.getNextRecurringBuyId();

        vm.expectEmit(true, true, false, true, address(dca));
        emit RecurringBuyCreated(nextRecurringBuyId, user);

        vm.prank(user);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
    }

    function testCreateRecurringBuyRevertsIfAmountToSpendIsZero() public {
        uint256 amountToSpend = 0;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 2 minutes;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__AmountIsZero.selector
        );
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
    }

    function testCreateRecurringBuyRevertsIfNotAccepintgNewRecurringBuys()
        public
    {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 2 minutes;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;

        vm.prank(signer);
        dca.setAcceptingNewRecurringBuys(false);

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage
                .DollarCostAverage__NotAcceptingNewRecurringBuys
                .selector
        );
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
    }

    function testCreateRecurringBuyRevertsIfEitherTokenIsInvalid() public {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = address(0);
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 2 minutes;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidTokenAddresses.selector
        );
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );

        tokenToSpend = token1;
        tokenToBuy = address(0);

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidTokenAddresses.selector
        );
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );

        tokenToSpend = token1;
        tokenToBuy = token1;

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidTokenAddresses.selector
        );
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
    }

    function testCreateRecurringBuyRevertsIfTimeIntervalIs0() public {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 0;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidTimeInterval.selector
        );
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
    }

    function testCreateRecurringBuyRevertsIfContractPaused() public {
        uint256 amountToSpend = 1 ether;
        address tokenToSpend = token1;
        address tokenToBuy = token2;
        uint256 timeIntervalInSeconds = 0;
        address paymentInterface = address(0);
        address dexRouter = defaultRouter;

        vm.prank(signer);
        dca.pause();

        vm.prank(user);
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
    /// Test for: cancelRecurringPayment
    /// -----------------------------------------------------------------------

    modifier createRecurringBuy(
        address tokenToSpend,
        address tokenToBuy,
        address paymentInterface
    ) {
        uint256 amountToSpend = 1 ether;
        uint256 timeIntervalInSeconds = 2 minutes;
        address dexRouter = defaultRouter;

        vm.prank(user);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
        _;
    }

    function testCancelRecurringPaymentSuccessAutomationNotZeroAddress()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;
        uint256[] memory idsBefore = dca.getSenderToIds(user);

        IDollarCostAverage.RecurringBuy memory buyBefore = dca.getRecurringBuy(
            currRecurringBuyId
        );
        IAutomationLayer.Account memory accountBefore = automation.getAccount(
            buyBefore.accountNumber
        );

        vm.prank(user);
        dca.cancelRecurringPayment(currRecurringBuyId);

        IDollarCostAverage.RecurringBuy memory buyAfter = dca.getRecurringBuy(
            currRecurringBuyId
        );
        IAutomationLayer.Account memory accountAfter = automation.getAccount(
            buyAfter.accountNumber
        );

        uint256[] memory idsAfter = dca.getSenderToIds(user);

        assertEq(uint8(buyBefore.status), uint8(IDollarCostAverage.Status.SET));
        assertEq(
            uint8(accountBefore.status),
            uint8(IAutomationLayer.Status.SET)
        );
        assertEq(
            uint8(buyAfter.status),
            uint8(IDollarCostAverage.Status.CANCELLED)
        );
        assertEq(
            uint8(accountAfter.status),
            uint8(IAutomationLayer.Status.CANCELLED)
        );
        assertEq(idsAfter.length, idsBefore.length - 1);
    }

    function testCancelRecurringPaymentSuccessAutomationZeroAddress()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;
        uint256[] memory idsBefore = dca.getSenderToIds(user);
        vm.prank(signer);
        dca.setAutomationLayer(address(0));

        IDollarCostAverage.RecurringBuy memory buyBefore = dca.getRecurringBuy(
            currRecurringBuyId
        );

        vm.prank(user);
        dca.cancelRecurringPayment(currRecurringBuyId);

        IDollarCostAverage.RecurringBuy memory buyAfter = dca.getRecurringBuy(
            currRecurringBuyId
        );
        IAutomationLayer.Account memory account = automation.getAccount(
            buyAfter.accountNumber
        );

        uint256[] memory idsAfter = dca.getSenderToIds(user);

        assertEq(uint8(buyBefore.status), uint8(IDollarCostAverage.Status.SET));
        assertEq(
            uint8(buyAfter.status),
            uint8(IDollarCostAverage.Status.CANCELLED)
        );
        assertEq(uint8(account.status), uint8(IAutomationLayer.Status.SET));
        assertEq(idsAfter.length, idsBefore.length - 1);
    }

    function testCancelRecurringPaymentEvent()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.expectEmit(true, true, false, false, address(dca));
        emit RecurringBuyCancelled(currRecurringBuyId, user);

        vm.prank(user);
        dca.cancelRecurringPayment(currRecurringBuyId);
    }

    function testCancelRecurringPaymentRevertsIfInvalidRecurringBuyId() public {
        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidRecurringBuyId.selector
        );
        dca.cancelRecurringPayment(recurringBuyId);
    }

    function testCancelRecurringPaymentRevertsIfCallerNotSender()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(address(1));
        vm.expectRevert(
            IDollarCostAverage
                .DollarCostAverage__CallerNotRecurringBuySender
                .selector
        );
        dca.cancelRecurringPayment(recurringBuyId);
    }

    function testCancelRecurringBuyRevertsIfContractPaused()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(signer);
        dca.pause();

        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        dca.cancelRecurringPayment(currRecurringBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: trigger
    /// -----------------------------------------------------------------------

    modifier transferFundsApproves(address sender) {
        vm.startPrank(sender);
        ERC20Mock(token1).approve(defaultRouter, type(uint256).max);
        ERC20Mock(token1).approve(address(dca), type(uint256).max);
        ERC20Mock(wrapNative).approve(defaultRouter, type(uint256).max);
        ERC20Mock(wrapNative).approve(address(dca), type(uint256).max);
        vm.stopPrank();
        _;
    }

    function testTriggerSuccessWhenCallerIsSender()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, PAYMENT_INTERFACE)
        createRecurringBuy(wrapNative, token2, address(0))
        createRecurringBuy(token1, wrapNative, address(0))
        transferFundsApproves(user)
    {
        // paymentInterface = address(0)
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 4;

        uint256 tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(user);
        dca.trigger(currRecurringBuyId);

        uint256 tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );

        uint256 fee = (buy.amountToSpend * 100) / 10000;
        uint256 currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);

        // paymentInterface != address(0)

        currRecurringBuyId = dca.getNextRecurringBuyId() - 3;

        tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);
        uint256 paymentInterfaceBalanceBefore = ERC20Mock(token1).balanceOf(
            PAYMENT_INTERFACE
        );

        vm.prank(user);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);
        uint256 paymentInterfaceBalanceAfter = ERC20Mock(token1).balanceOf(
            PAYMENT_INTERFACE
        );

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - buy.amountToSpend
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);
        assertEq(
            paymentInterfaceBalanceAfter,
            paymentInterfaceBalanceBefore + fee / 2
        );

        // tokenToSpend = wrapNative

        currRecurringBuyId = dca.getNextRecurringBuyId() - 2;

        tokenToSpendBalanceBefore = ERC20Mock(wrapNative).balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(user);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = ERC20Mock(wrapNative).balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);

        // tokenToBuy = wrapNative

        currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(wrapNative).balanceOf(user);

        vm.prank(user);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(wrapNative).balanceOf(user);

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);

        // tokenToSpend not token1 or token2
        anotherToken.mint(user, INITAL_USER_FUNDS);

        vm.startPrank(user);
        anotherToken.approve(address(dca), type(uint256).max);
        dca.createRecurringBuy(
            1 ether,
            address(anotherToken),
            token2,
            2 minutes,
            address(0),
            defaultRouter
        );
        vm.stopPrank();

        currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        tokenToSpendBalanceBefore = anotherToken.balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(user);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = anotherToken.balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);
    }

    function testTriggerSuccessWhenCallerIsNOTSender()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, PAYMENT_INTERFACE)
        createRecurringBuy(wrapNative, token2, address(0))
        createRecurringBuy(token1, wrapNative, address(0))
        transferFundsApproves(makeAddr("anotherUser"))
        transferFundsApproves(user)
    {
        address anotherUser = makeAddr("anotherUser");
        vm.prank(signer);
        ERC20Mock(duhToken).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);

        // paymentInterface = address(0)
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 4;

        uint256 tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(anotherUser);
        dca.trigger(currRecurringBuyId);

        uint256 tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );

        uint256 fee = (buy.amountToSpend * 100) / 10000;
        uint256 currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);

        // paymentInterface != address(0)

        currRecurringBuyId = dca.getNextRecurringBuyId() - 3;

        tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);
        uint256 paymentInterfaceBalanceBefore = ERC20Mock(token1).balanceOf(
            PAYMENT_INTERFACE
        );

        vm.prank(anotherUser);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);
        uint256 paymentInterfaceBalanceAfter = ERC20Mock(token1).balanceOf(
            PAYMENT_INTERFACE
        );

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - buy.amountToSpend
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);
        assertEq(
            paymentInterfaceBalanceAfter,
            paymentInterfaceBalanceBefore + fee / 2
        );

        // tokenToSpend = wrapNative

        currRecurringBuyId = dca.getNextRecurringBuyId() - 2;

        tokenToSpendBalanceBefore = ERC20Mock(wrapNative).balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(anotherUser);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = ERC20Mock(wrapNative).balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);

        // tokenToBuy = wrapNative

        currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(wrapNative).balanceOf(user);

        vm.prank(anotherUser);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(wrapNative).balanceOf(user);

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);

        // tokenToSpend not token1 or token2
        anotherToken.mint(user, INITAL_USER_FUNDS);

        vm.startPrank(user);
        anotherToken.approve(address(dca), type(uint256).max);
        dca.createRecurringBuy(
            1 ether,
            address(anotherToken),
            token2,
            2 minutes,
            address(0),
            defaultRouter
        );
        vm.stopPrank();

        currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        tokenToSpendBalanceBefore = anotherToken.balanceOf(user);
        tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(anotherUser);
        dca.trigger(currRecurringBuyId);

        tokenToSpendBalanceAfter = anotherToken.balanceOf(user);
        tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        buy = dca.getRecurringBuy(currRecurringBuyId);

        fee = (buy.amountToSpend * 100) / 10000;
        currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);
    }

    function testTriggerSuccessWhenCallerIsNOTSenderAndAutomationFeeIs0()
        public
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(makeAddr("anotherUser"))
        transferFundsApproves(user)
    {
        address anotherUser = makeAddr("anotherUser");
        vm.startPrank(signer);
        ERC20Mock(duhToken).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        automation.setAutomationFee(0);
        vm.stopPrank();

        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        uint256 tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.prank(anotherUser);
        dca.trigger(currRecurringBuyId);

        uint256 tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );

        uint256 fee = (buy.amountToSpend * 100) / 10000;
        uint256 currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);
    }

    function testTriggerSuccessAutomationLayerIsZeroAddress()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, PAYMENT_INTERFACE)
        createRecurringBuy(wrapNative, token2, address(0))
        createRecurringBuy(token1, wrapNative, address(0))
        transferFundsApproves(user)
    {
        vm.prank(signer);
        dca.setAutomationLayer(address(0));

        address owner = dca.owner();
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 4;

        uint256 tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);
        uint256 automantionBalanceBefore = ERC20Mock(token1).balanceOf(
            address(automation)
        );
        uint256 ownerBalanceBefore = ERC20Mock(token1).balanceOf(owner);

        vm.prank(user);
        dca.trigger(currRecurringBuyId);

        uint256 tokenToSpendBalanceAfter = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceAfter = ERC20Mock(token2).balanceOf(user);
        uint256 automantionBalanceAfter = ERC20Mock(token1).balanceOf(
            address(automation)
        );
        uint256 ownerBalanceAfter = ERC20Mock(token1).balanceOf(owner);

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );

        uint256 fee = (buy.amountToSpend * 100) / 10000;
        uint256 currTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(
            tokenToSpendBalanceAfter,
            tokenToSpendBalanceBefore - (buy.amountToSpend - fee / 2)
        );
        assertGt(tokenToBuyBalanceAfter, tokenToBuyBalanceBefore);
        assertEq(buy.paymentDue, currTimestamp + buy.timeIntervalInSeconds);
        assertEq(automantionBalanceAfter, automantionBalanceBefore);
        assertTrue(ownerBalanceAfter > ownerBalanceBefore);
    }

    function testTriggerEvent()
        public
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.expectEmit(true, true, false, false, address(dca));

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = uint256(0);
        amounts[1] = uint256(0);

        emit PaymentTransferred(currRecurringBuyId, user, amounts);

        vm.prank(user);
        dca.trigger(currRecurringBuyId);
    }

    function testTriggerRevertsIfStatusIsNotSetOrIfPaymentIsNotDue()
        public
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.startPrank(user);
        dca.trigger(currRecurringBuyId);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidRecurringBuy.selector
        );
        dca.trigger(currRecurringBuyId);

        vm.warp(block.timestamp + 1 hours);
        dca.cancelRecurringPayment(currRecurringBuyId);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidRecurringBuy.selector
        );
        dca.trigger(currRecurringBuyId);
        vm.stopPrank();
    }

    function testTriggerRevertsIfContractPaused()
        public
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(signer);
        dca.pause();

        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        dca.trigger(currRecurringBuyId);
    }

    function testTrasferFundsRevertsIfNotEnoughAllowance()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(user);
        vm.expectRevert(
            IDollarCostAverage
                .DollarCostAverage__TokenNotEnoughAllowance
                .selector
        );
        dca.trigger(currRecurringBuyId);
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAutomationLayer
    /// -----------------------------------------------------------------------

    function testSetAutomationLayerSuccess() public {
        address newAutomationLayerAddress = makeAddr("newAutomationLayer");

        address automationLayerBefore = address(dca.getAutomationLayer());

        vm.prank(signer);
        dca.setAutomationLayer(newAutomationLayerAddress);

        address automationLayerAfter = address(dca.getAutomationLayer());

        assertEq(automationLayerBefore, address(automation));
        assertEq(automationLayerAfter, newAutomationLayerAddress);
    }

    function testSetAutomationLayerEvent() public {
        address newAutomationLayerAddress = makeAddr("newAutomationLayer");

        vm.expectEmit(true, true, false, false, address(dca));
        emit AutomationLayerSet(signer, newAutomationLayerAddress);

        vm.prank(signer);
        dca.setAutomationLayer(newAutomationLayerAddress);
    }

    function testSetAutomationLayerRevertsIfCallerNotAllowed() public {
        address newAutomationLayerAddress = makeAddr("newAutomationLayer");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setAutomationLayer(newAutomationLayerAddress);
    }

    function testSetAutomationLayerRevertsIfContractPaused() public {
        address newAutomationLayerAddress = makeAddr("newAutomationLayer");

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setAutomationLayer(newAutomationLayerAddress);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setDefaultRouter
    /// -----------------------------------------------------------------------

    function testSetDefaultRouterSuccess() public {
        address newDefaultRouter = makeAddr("newDefaultRouter");

        address defaultRouterBefore = dca.getDefaultRouter();

        vm.prank(signer);
        dca.setDefaultRouter(newDefaultRouter);

        address defaultRouterAfter = dca.getDefaultRouter();

        assertEq(defaultRouterBefore, defaultRouter);
        assertEq(defaultRouterAfter, newDefaultRouter);
    }

    function testSetDefaultRouterEvent() public {
        address newDefaultRouter = makeAddr("newDefaultRouter");

        vm.expectEmit(true, true, false, false, address(dca));
        emit DefaultRouterSet(signer, newDefaultRouter);

        vm.prank(signer);
        dca.setDefaultRouter(newDefaultRouter);
    }

    function testSetDefaultRouterRevertsIfGivenAddressIs0() public {
        address newDefaultRouter = address(0);

        vm.prank(signer);
        vm.expectRevert(
            IDollarCostAverage
                .DollarCostAverage__InvalidDefaultRouterAddress
                .selector
        );
        dca.setDefaultRouter(newDefaultRouter);
    }

    function testSetDefaultRouterRevertsIfCallerNotAllowed() public {
        address newDefaultRouter = makeAddr("newDefaultRouter");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setDefaultRouter(newDefaultRouter);
    }

    function testSetDefaultRouterRevertsIfContractPaused() public {
        address newDefaultRouter = makeAddr("newDefaultRouter");

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setDefaultRouter(newDefaultRouter);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAcceptingNewRecurringBuys
    /// -----------------------------------------------------------------------

    function testSetAcceptingNewRecurringBuysSuccess() public {
        bool newAcceptingNewRecurringBuys = false;

        bool acceptingNewRecurringBuysBefore = dca
            .getAcceptingNewRecurringBuys();

        vm.prank(signer);
        dca.setAcceptingNewRecurringBuys(newAcceptingNewRecurringBuys);

        bool acceptingNewRecurringBuysAfter = dca
            .getAcceptingNewRecurringBuys();

        assertEq(acceptingNewRecurringBuysBefore, true);
        assertEq(acceptingNewRecurringBuysAfter, newAcceptingNewRecurringBuys);
    }

    function testSetAcceptingNewRecurringBuysEvent() public {
        bool newAcceptingNewRecurringBuys = false;

        vm.expectEmit(true, false, false, true, address(dca));
        emit AcceptingRecurringBuysSet(signer, newAcceptingNewRecurringBuys);

        vm.prank(signer);
        dca.setAcceptingNewRecurringBuys(newAcceptingNewRecurringBuys);
    }

    function testSetAcceptingNewRecurringBuysRevertsIfCallerNotAllowed()
        public
    {
        bool newAcceptingNewRecurringBuys = false;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setAcceptingNewRecurringBuys(newAcceptingNewRecurringBuys);
    }

    function testSetAcceptingNewRecurringBuysRevertsIfContractPaused() public {
        bool newAcceptingNewRecurringBuys = false;

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setAcceptingNewRecurringBuys(newAcceptingNewRecurringBuys);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setFee
    /// -----------------------------------------------------------------------

    function testSetFeeSuccess() public {
        uint256 newFee = 500;

        uint256 feeBefore = dca.getFee();

        vm.prank(signer);
        dca.setFee(newFee);

        uint256 feeAfter = dca.getFee();

        assertEq(feeBefore, 100);
        assertEq(feeAfter, newFee);
    }

    function testSetFeeEvent() public {
        uint256 newFee = 500;

        vm.expectEmit(true, false, false, true, address(dca));
        emit FeeSet(signer, newFee);

        vm.prank(signer);
        dca.setFee(newFee);
    }

    function testSetFeeRevertsIfCallerNotAllowed() public {
        uint256 newFee = 500;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setFee(newFee);
    }

    function testSetFeeRevertsIfContractPaused() public {
        uint256 newFee = 500;

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setFee(newFee);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setContractFeeShare
    /// -----------------------------------------------------------------------

    function testSetContractFeeShareSuccess() public {
        uint256 newContractFeeShare = 6000;

        uint256 contractFeeShareBefore = dca.getContractFeeShare();

        vm.prank(signer);
        dca.setContractFeeShare(newContractFeeShare);

        uint256 contractFeeShareAfter = dca.getContractFeeShare();

        assertEq(contractFeeShareBefore, 5000);
        assertEq(contractFeeShareAfter, newContractFeeShare);
    }

    function testSetContractFeeEvent() public {
        uint256 newContractFeeShare = 6000;

        vm.expectEmit(true, false, false, true, address(dca));
        emit ContractFeeShareSet(signer, newContractFeeShare);

        vm.prank(signer);
        dca.setContractFeeShare(newContractFeeShare);
    }

    function testSetContractFeeRevertsIfCallerNotAllowed() public {
        uint256 newContractFeeShare = 6000;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setContractFeeShare(newContractFeeShare);
    }

    function testSetContractFeeRevertsIfContractPaused() public {
        uint256 newContractFeeShare = 6000;

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setContractFeeShare(newContractFeeShare);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setSlippagePercentage
    /// -----------------------------------------------------------------------

    function testSetSlippagePercentageSuccess() public {
        uint256 newSlippagePercentage = 500;

        uint256 slippagePercentageBefore = dca.getSlippagePercentage();

        vm.prank(signer);
        dca.setSlippagePercentage(newSlippagePercentage);

        uint256 slippagePercentageAfter = dca.getSlippagePercentage();

        assertEq(slippagePercentageBefore, 100);
        assertEq(slippagePercentageAfter, newSlippagePercentage);
    }

    function testSetSlippagePercentageEvent() public {
        uint256 newSlippagePercentage = 500;

        vm.expectEmit(true, false, false, true, address(dca));
        emit SlippagePercentageSet(signer, newSlippagePercentage);

        vm.prank(signer);
        dca.setSlippagePercentage(newSlippagePercentage);
    }

    function testSetSlippagePercentageRevertsIfCallerNotAllowed() public {
        uint256 newSlippagePercentage = 500;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setSlippagePercentage(newSlippagePercentage);
    }

    function testSetSlippagePercentageRevertsIfContractPaused() public {
        uint256 newSlippagePercentage = 500;

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setSlippagePercentage(newSlippagePercentage);
        vm.stopPrank();
    }

    /// -----------------------------------------------------------------------
    /// Test for: setDuh
    /// -----------------------------------------------------------------------

    function testSetDuhSuccess() public {
        address newDuh = makeAddr("duh");

        address duhBefore = dca.getDuh();

        vm.prank(signer);
        dca.setDuh(newDuh);

        address duhAfter = dca.getDuh();

        assertEq(duhBefore, address(duhToken));
        assertEq(duhAfter, newDuh);
    }

    function testSetDuhEvent() public {
        address newDuh = makeAddr("duh");

        vm.expectEmit(true, false, false, true, address(dca));
        emit DuhTokenSet(signer, newDuh);

        vm.prank(signer);
        dca.setDuh(newDuh);
    }

    function testSetDuhRevertsIfCallerNotAllowed() public {
        address newDuh = makeAddr("duh");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setDuh(newDuh);
    }

    function testSetDuhRevertsIfContractPaused() public {
        address newDuh = makeAddr("duh");

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setDuh(newDuh);
        vm.stopPrank();
    }

    function testSetDuhRevertsIfNewDuhIsAddress0() public {
        address newDuh = address(0);

        vm.prank(signer);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidTokenAddresses.selector
        );
        dca.setDuh(newDuh);
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAllowedERC20s
    /// -----------------------------------------------------------------------

    function testSetAllowedERC20sSuccess() public {
        address newDuh = makeAddr("duh");

        address duhBefore = dca.getDuh();

        vm.prank(signer);
        dca.setDuh(newDuh);

        address duhAfter = dca.getDuh();

        assertEq(duhBefore, address(duhToken));
        assertEq(duhAfter, newDuh);
    }

    function testSetAllowedERC20sEvent() public {
        address newDuh = makeAddr("duh");

        vm.expectEmit(true, false, false, true, address(dca));
        emit DuhTokenSet(signer, newDuh);

        vm.prank(signer);
        dca.setDuh(newDuh);
    }

    function testSetAllowedERC20sRevertsIfCallerNotAllowed() public {
        address newDuh = makeAddr("duh");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        dca.setDuh(newDuh);
    }

    function testSetAllowedERC20sRevertsIfContractPaused() public {
        address newDuh = makeAddr("duh");

        vm.startPrank(signer);
        dca.pause();
        vm.expectRevert("Pausable: paused");
        dca.setDuh(newDuh);
        vm.stopPrank();
    }

    function testSetAllowedERC20sRevertsIfTokenIsAddress0() public {
        address newDuh = address(0);

        vm.prank(signer);
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidTokenAddresses.selector
        );
        dca.setDuh(newDuh);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getNextRecurringBuyId
    /// -----------------------------------------------------------------------

    function testGetNextRecurringBuyId()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 nextRecurringBuyId = dca.getNextRecurringBuyId();

        assertEq(nextRecurringBuyId, 2);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getDefaultRouter
    /// -----------------------------------------------------------------------

    function testGetDefaultRouter() public {
        address currDefaultRouter = dca.getDefaultRouter();

        assertEq(currDefaultRouter, defaultRouter);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAutomationLayer
    /// -----------------------------------------------------------------------

    function testGetAutomationLayer() public {
        address currAutomationLayerAddress = address(dca.getAutomationLayer());

        assertEq(currAutomationLayerAddress, address(automation));
    }

    /// -----------------------------------------------------------------------
    /// Test for: checkTrigger
    /// -----------------------------------------------------------------------

    function testCheckTriggerSuccess()
        public
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;
        bool canAutomate = dca.checkTrigger(recurringBuyId);

        assertEq(canAutomate, true);
    }

    function testCheckTriggerFalsePath1()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(user);
        dca.cancelRecurringPayment(recurringBuyId);

        bool canAutomate = dca.checkTrigger(recurringBuyId);

        assertEq(canAutomate, false);
    }

    function testCheckTriggerFalsePath2()
        public
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(user);
        dca.trigger(recurringBuyId);

        bool canAutomate = dca.checkTrigger(recurringBuyId);

        assertEq(canAutomate, false);
    }

    modifier createRecurringBuyForUser(
        address user_,
        address tokenToSpend,
        address tokenToBuy,
        address paymentInterface
    ) {
        uint256 amountToSpend = 1 ether;
        uint256 timeIntervalInSeconds = 2 minutes;
        address dexRouter = defaultRouter;

        vm.prank(user_);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            dexRouter
        );
        _;
    }

    function testCheckTriggerFalsePath3()
        public
        createRecurringBuyForUser(
            makeAddr("anotherUser"),
            token1,
            token2,
            address(0)
        )
    {
        address anotherUser = makeAddr("anotherUser");
        vm.prank(anotherUser);
        ERC20Mock(token1).approve(address(dca), type(uint256).max);

        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        bool canAutomate = dca.checkTrigger(recurringBuyId);

        assertEq(canAutomate, false);
    }

    function testCheckTriggerFalsePath4()
        public
        createRecurringBuyForUser(
            makeAddr("anotherUser"),
            token1,
            token2,
            address(0)
        )
    {
        address anotherUser = makeAddr("anotherUser");
        vm.prank(anotherUser);
        ERC20Mock(token1).mint(anotherUser, 1 ether);

        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        bool canAutomate = dca.checkTrigger(recurringBuyId);

        assertEq(canAutomate, false);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getCurrentBlockTimestamp
    /// -----------------------------------------------------------------------

    function testGetCurrentBlockTimestamp() public {
        uint256 blockTimestamp = dca.getCurrentBlockTimestamp();

        assertEq(blockTimestamp, block.timestamp);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getRecurringBuy
    /// -----------------------------------------------------------------------

    function testGetRecurringBuy()
        public
        createRecurringBuy(token1, token2, address(0))
    {
        uint256 recurringBuyId = dca.getNextRecurringBuyId() - 1;

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            recurringBuyId
        );

        uint256 amountToSpend = 1 ether;
        uint256 timeIntervalInSeconds = 2 minutes;
        address dexRouter = defaultRouter;

        assertEq(buy.sender, user);
        assertEq(buy.amountToSpend, amountToSpend);
        assertEq(buy.tokenToSpend, token1);
        assertEq(buy.tokenToBuy, token2);
        assertEq(buy.timeIntervalInSeconds, timeIntervalInSeconds);
        assertEq(buy.paymentInterface, address(0));
        assertEq(buy.dexRouter, dexRouter);
        assertEq(buy.paymentDue, block.timestamp);
        assertEq(buy.accountNumber, 0);
        assertEq(uint8(buy.status), uint8(IDollarCostAverage.Status.SET));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAcceptingNewRecurringBuys
    /// -----------------------------------------------------------------------

    function testGetAcceptingNewRecurringBuys() public {
        bool acceptingNewRecurringBuys = dca.getAcceptingNewRecurringBuys();

        assertEq(acceptingNewRecurringBuys, true);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getWrapNative
    /// -----------------------------------------------------------------------

    function testGetWrapNative() public {
        address wNative = dca.getWrapNative();

        assertEq(wNative, wrapNative);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getRangeOfRecurringBuys
    /// -----------------------------------------------------------------------

    function testGetRangeOfRecurringBuys()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
    {
        IDollarCostAverage.RecurringBuy[] memory buys = dca
            .getRangeOfRecurringBuys(2, 4);

        assertEq(buys.length, 3);
    }

    function testGetRangeOfRecurringBuysRevertsIfInvalidRange()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
    {
        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getRangeOfRecurringBuys(3, 1);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getRangeOfRecurringBuys(2, 6);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getValidRangeOfRecurringBuys
    /// -----------------------------------------------------------------------

    // reformulate
    function testGetValidRangeOfRecurringBuys()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        vm.prank(user);
        dca.cancelRecurringPayment(2);

        IDollarCostAverage.RecurringBuy[] memory buys = dca
            .getValidRangeOfRecurringBuys(1, 5);

        assertEq(buys.length, 4);
    }

    function testGetValidRangeOfRecurringBuysRevertsIfInvalidRange()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        vm.prank(user);
        dca.cancelRecurringPayment(2);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getValidRangeOfRecurringBuys(3, 1);

        vm.expectRevert(
            IDollarCostAverage.DollarCostAverage__InvalidIndexRange.selector
        );
        dca.getValidRangeOfRecurringBuys(2, 8);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getFee
    /// -----------------------------------------------------------------------

    function testGetFee() public {
        uint256 fee = dca.getFee();

        assertEq(fee, 100);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getContractFeeShare
    /// -----------------------------------------------------------------------

    function testGetContractFeeShare() public {
        uint256 contractFeeShare = dca.getContractFeeShare();

        assertEq(contractFeeShare, 5000);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getSlippagePercentage
    /// -----------------------------------------------------------------------

    function testGetSlippagePercentage() public {
        uint256 slippagePercentage = dca.getSlippagePercentage();

        assertEq(slippagePercentage, 100);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getDuh
    /// -----------------------------------------------------------------------

    function testGetDuh() public {
        address duh = dca.getDuh();

        assertEq(duh, address(duhToken));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getSenderToIds
    /// -----------------------------------------------------------------------

    function testGetSenderToIds()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
    {
        uint256[] memory ids = dca.getSenderToIds(user);

        assertEq(ids.length, 4);
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
        assertEq(ids[2], 2);
        assertEq(ids[3], 3);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAllowedERC20s
    /// -----------------------------------------------------------------------

    function testGetAllowedERC20s() public {
        assertTrue(dca.getAllowedERC20s(token1));
        assertTrue(!dca.getAllowedERC20s(msg.sender));
    }

    /// -----------------------------------------------------------------------
    /// Test for: isRecurringBuyValid
    /// -----------------------------------------------------------------------

    function testIsRecurringBuyValidSuccess()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 recurringBuyId = 1;
        bool isValid = dca.isRecurringBuyValid(recurringBuyId);

        assertEq(isValid, true);
    }

    function testIsRecurringBuyValidFailPath1()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 recurringBuyId = 1;

        vm.prank(user);
        dca.cancelRecurringPayment(recurringBuyId);

        bool isValid = dca.isRecurringBuyValid(recurringBuyId);

        assertEq(isValid, false);
    }

    function testIsRecurringBuyValidFailPath2()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        transferFundsApproves(user)
    {
        uint256 recurringBuyId = 1;

        vm.prank(user);
        dca.trigger(recurringBuyId);

        bool isValid = dca.isRecurringBuyValid(recurringBuyId);

        assertEq(isValid, false);
    }

    function testIsRecurringBuyValidFailPath3()
        public
        createRecurringBuyForUser(
            makeAddr("anotherUser"),
            token1,
            token2,
            address(0)
        )
        createRecurringBuyForUser(
            makeAddr("anotherUser"),
            token1,
            token2,
            address(0)
        )
    {
        uint256 recurringBuyId = 1;

        vm.prank(makeAddr("anotherUser"));
        ERC20Mock(token1).approve(address(dca), type(uint256).max);

        bool isValid = dca.isRecurringBuyValid(recurringBuyId);

        assertEq(isValid, false);
    }

    function testIsRecurringBuyValidFailPath4()
        public
        createRecurringBuyForUser(
            makeAddr("anotherUser"),
            token1,
            token2,
            address(0)
        )
        createRecurringBuyForUser(
            makeAddr("anotherUser"),
            token1,
            token2,
            address(0)
        )
    {
        uint256 recurringBuyId = 1;

        vm.prank(makeAddr("anotherUser"));
        ERC20Mock(token1).mint(user, 1 ether);

        bool isValid = dca.isRecurringBuyValid(recurringBuyId);

        assertEq(isValid, false);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getRecurringBuyFromIds
    /// -----------------------------------------------------------------------

    function testGetRecurringBuyFromIds()
        public
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
        createRecurringBuy(token1, token2, address(0))
    {
        uint256[] memory recBuyIds = new uint256[](5);
        recBuyIds[0] = 1;
        recBuyIds[1] = 2;
        recBuyIds[2] = 3;
        recBuyIds[3] = 4;
        recBuyIds[4] = 5;
        IDollarCostAverage.RecurringBuy[] memory recBuys = dca
            .getRecurringBuyFromIds(recBuyIds);

        assertEq(recBuys.length, 5);
        assertEq(
            uint8(recBuys[0].status),
            uint8(IDollarCostAverage.Status.SET)
        );
        assertEq(
            uint8(recBuys[1].status),
            uint8(IDollarCostAverage.Status.SET)
        );
        assertEq(
            uint8(recBuys[2].status),
            uint8(IDollarCostAverage.Status.SET)
        );
        assertEq(
            uint8(recBuys[3].status),
            uint8(IDollarCostAverage.Status.SET)
        );
        assertEq(
            uint8(recBuys[4].status),
            uint8(IDollarCostAverage.Status.SET)
        );
    }
}
