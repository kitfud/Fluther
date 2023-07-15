// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM)
 *  @title Dollar cost averaging application smart contract
 *  This code is proprietary and confidential. All rights reserved.
 *  Unauthorized copying of this file, via any medium is strictly prohibited.
 *  Proprietary code by Levi Webb
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {IDollarCostAveraging} from "./interfaces/IDollarCostAveraging.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IAutomationLayer} from "./interfaces/IAutomationLayer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract DollarCostAverage is
    IDollarCostAveraging,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /* solhint-disable */
    // base types
    uint256 private s_nextRecurringBuyId;
    address private s_defaultRouter;
    address private s_automationLayerAddress;
    bool private s_acceptingNewRecurringBuys;

    // mappings and arrays
    mapping(uint256 recurringBuyId => RecurringBuys data)
        private s_recurringBuys;

    // constants
    address private constant WMATIC =
        0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(address defaultRouter, address automationLayerAddress) {
        s_defaultRouter = defaultRouter;
        s_automationLayerAddress = automationLayerAddress;
        s_acceptingNewRecurringBuys = true;
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    function createRecurringBuy(
        uint256 _amount,
        address _token1,
        address _token2,
        uint256 _timeIntervalSeconds,
        address _interface,
        address dexRouter
    ) external nonReentrant whenNotPaused {
        require(_amount > 0, "Payment amount must be greater than zero");
        require(
            s_acceptingNewRecurringBuys,
            "No longer accepting new recurring buys"
        );
        RecurringBuys memory buy = RecurringBuys(
            msg.sender,
            _token1,
            _token2,
            _amount,
            _timeIntervalSeconds,
            _interface,
            dexRouter == address(0) ? s_defaultRouter : dexRouter,
            block.timestamp,
            Status.SET
        );

        uint256 accountNumber = IAutomationLayer(s_automationLayerAddress)
            .createAccount(s_nextRecurringBuyId);

        s_recurringBuys[s_nextRecurringBuyId] = buy;
        ++s_nextRecurringBuyId;

        emit RecurringBuyCreated(
            s_nextRecurringBuyId,
            accountNumber,
            msg.sender,
            buy
        );
    }

    function cancelRecurringPayment(
        uint256 recurringBuyId
    ) external nonReentrant whenNotPaused {
        require(recurringBuyId < s_nextRecurringBuyId, "Invalid payment index");

        RecurringBuys storage buy = s_recurringBuys[recurringBuyId];

        require(
            msg.sender == buy.sender,
            "Only the payment sender or recipient can cancel the recurring payment."
        );

        buy.status = Status.CANCELLED;

        emit RecurringBuyCancelled(recurringBuyId, buy.sender);
    }

    function transferFunds(
        uint256 recurringBuyId
    ) public nonReentrant whenNotPaused {
        RecurringBuys storage buy = s_recurringBuys[recurringBuyId];
        require(
            buy.status == Status.SET,
            "The recurring payment has been canceled."
        );

        require(
            block.timestamp >= buy.paymentDue,
            "Not enough time has passed since the last transfer."
        );
        buy.paymentDue += buy.timeIntervalInSeconds;
        uint256 buyAmount = (buy.amount * 990) / 1000;
        uint256 fee = buy.amount - buyAmount;
        uint256 interfaceFee = fee / 3;

        uint256 contractFee = fee - interfaceFee;

        emit PaymentTransferred(recurringBuyId);

        require(
            IERC20(buy.token1).transferFrom(buy.sender, owner(), contractFee),
            "contract fee Token transfer failed."
        );

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(buy.dexRouter);

        IERC20(buy.token1).approve(buy.dexRouter, buyAmount);

        address[] memory path;
        if (buy.token1 == WMATIC || buy.token2 == WMATIC) {
            path = new address[](2);
            path[0] = buy.token1;
            path[1] = buy.token2;
        } else {
            path = new address[](3);
            path[0] = buy.token1;
            path[1] = WMATIC;
            path[2] = buy.token2;
        }

        uint256[] memory getAmountsOut = uniswapRouter.getAmountsOut(
            buyAmount,
            path
        );

        //uint256 amountOutMin = (getAmountsOut[0] * 99) / 100;
        uint256 amountOutMin = (getAmountsOut[getAmountsOut.length - 1] * 99) /
            1000;

        uniswapRouter.swapExactTokensForTokens(
            buyAmount,
            amountOutMin,
            path,
            buy.sender,
            block.timestamp
        );
    }

    function trigger(uint256 accountNumber) external {
        transferFunds(accountNumber);
    }

    function setAutomationLayerAddress(
        address automationLayerAddress
    ) external onlyOwner {
        s_automationLayerAddress = automationLayerAddress;
    }

    function setDefaultRouter(address defaultRouter) external onlyOwner {
        s_defaultRouter = defaultRouter;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    function checkTrigger(uint256 recurringBuyId) external view returns (bool) {
        RecurringBuys storage buy = s_recurringBuys[recurringBuyId];
        return buy.paymentDue < block.timestamp && buy.status == Status.SET;
    }

    function getCurrentBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function getPaymentDue(
        uint256 recurringBuyId
    ) external view returns (uint256) {
        require(recurringBuyId < s_nextRecurringBuyId, "Invalid payment index");

        RecurringBuys storage buy = s_recurringBuys[recurringBuyId];

        return buy.paymentDue;
    }

    // function getRecurringPaymentIndices(
    //     address account
    // ) external view returns (uint256[] memory) {
    //     return addressToIndices[account];
    // }

    function isSubscriptionValid(
        uint256 recurringBuyId
    ) external view returns (bool) {
        require(recurringBuyId < s_nextRecurringBuyId, "Invalid payment index");

        RecurringBuys storage buy = s_recurringBuys[recurringBuyId];

        uint256 oneDayInSeconds = 24 * 60 * 60; // Number of seconds in a day

        return buy.paymentDue + oneDayInSeconds > block.timestamp;
    }

    function isPaymentCanceled(
        uint256 recurringBuyId
    ) external view returns (Status) {
        require(recurringBuyId < s_nextRecurringBuyId, "Invalid payment index");

        RecurringBuys storage payment = s_recurringBuys[recurringBuyId];

        return payment.status;
    }
}
