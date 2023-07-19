// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AutomationLayer} from "../../src/AutomationLayer.sol";
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

    address public user = makeAddr("user");

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
        token1 = deployer.token1();
        token2 = deployer.token2();
        defaultRouter = deployer.defaultRouter();

        ERC20Mock(token1).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token2).mint(defaultRouter, INITAL_DEX_ERC20_FUNDS);
        ERC20Mock(token1).mint(user, INITAL_USER_ERC20_FUNDS);

        vm.deal(user, INITAL_USER_FUNDS);
    }

    /// -----------------------------------------------------------------------
    /// Test for: createRecurringBuy
    /// -----------------------------------------------------------------------

    function testCreateRecurringBuySuccess() public {
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
    }

    /// -----------------------------------------------------------------------
    /// Test for: cancelRecurringPayment
    /// -----------------------------------------------------------------------

    modifier createRecurringBuy() {
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
        _;
    }

    function testCancelRecurringPaymentSuccess() public createRecurringBuy {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        vm.prank(user);
        dca.cancelRecurringPayment(currRecurringBuyId);

        IDollarCostAverage.RecurringBuy memory buy = dca.getRecurringBuy(
            currRecurringBuyId
        );

        assertEq(uint8(buy.status), uint8(IDollarCostAverage.Status.CANCELLED));
    }

    /// -----------------------------------------------------------------------
    /// Test for: transferFunds
    /// -----------------------------------------------------------------------

    function testTransferFundsSuccess() public createRecurringBuy {
        uint256 currRecurringBuyId = dca.getNextRecurringBuyId() - 1;

        uint256 tokenToSpendBalanceBefore = ERC20Mock(token1).balanceOf(user);
        uint256 tokenToBuyBalanceBefore = ERC20Mock(token2).balanceOf(user);

        vm.startPrank(user);
        ERC20Mock(token1).approve(defaultRouter, type(uint256).max);
        ERC20Mock(token1).approve(address(dca), type(uint256).max);
        dca.transferFunds(currRecurringBuyId);
        vm.stopPrank();

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
}
