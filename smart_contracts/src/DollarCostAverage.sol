// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM) and @EWCunha
 *  @title Dollar cost averaging application smart contract
 *  This code is proprietary and confidential. All rights reserved.
 *  Unauthorized copying of this file, via any medium is strictly prohibited.
 *  Proprietary code by Levi Webb
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {IDollarCostAverage} from "./interfaces/IDollarCostAverage.sol";
import {IAutomatedContract} from "./interfaces/IAutomatedContract.sol";
import {IDEXRouter} from "./interfaces/IDEXRouter.sol";
import {IDEXFactory} from "./interfaces/IDEXFactory.sol";
import {IAutomationLayer} from "./interfaces/IAutomationLayer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Security} from "./Security.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract DollarCostAverage is IDollarCostAverage, IAutomatedContract, Security {
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /* solhint-disable */
    // base types
    uint256 private s_nextRecurringBuyId;
    address private s_defaultRouter;
    IAutomationLayer private s_automationLayer;
    bool private s_acceptingNewRecurringBuys;
    address private immutable i_wrapNative;

    // mappings and arrays
    mapping(uint256 /* recurringBuyId */ => RecurringBuy /* data */)
        private s_recurringBuys;

    // constants
    uint256 private constant FEE = 100; // over 10000
    uint256 private constant PRECISION = 10000;
    uint256 private constant CONTRACT_FEE_SHARE = 5000; // over 10000
    uint256 private SLIPPAGE_PERCENTAGE = 100; // over 10000

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers (or functions as modifiers)
    /// -----------------------------------------------------------------------

    /** @dev Checks if this contract has enough allowance to perform the transfer of funds for the recurring buy automation.
     *  It reverts if allowance is not enough.
     *  @param token: address of the ERC20 token to be spent.
     *  @param owner_: owner address of the ERC20 token amount.
     *  @param amount: amount of the token to spend.
     */
    function __haveEnoughAllowance(
        address token,
        address owner_,
        uint256 amount
    ) private view {
        if (IERC20(token).allowance(owner_, address(this)) < amount) {
            revert DollarCostAverage__TokenNotEnoughAllowance();
        }
    }

    /** @dev Validates the given range of recurring buy IDs. It reverts if range is not valid.
     *  @param startRecBuyId: starting recurring buy ID.
     *  @param endRecBuyId: ending recurring buy ID.
     */
    function __validateIndexRange(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    ) private view {
        if (
            !(startRecBuyId < endRecBuyId) ||
            !(endRecBuyId < s_nextRecurringBuyId)
        ) {
            revert DollarCostAverage__InvalidIndexRange();
        }
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /** @notice constructor logic.
     *  @param defaultRouter: default DEX router address.
     *  @param automationLayerAddress: address for the automation layer smart contract.
     *  @param _wrapNative: ERC20 smart contract address for the wrapped version of the native blockchain coin.
     */
    constructor(
        address defaultRouter,
        address automationLayerAddress,
        address _wrapNative
    ) Security(msg.sender) {
        if (defaultRouter == address(0)) {
            revert DollarCostAverage__InvalidDefaultRouterAddress();
        }
        if (automationLayerAddress == address(0)) {
            revert DollarCostAverage__InvalidAutomationLayerAddress();
        }

        s_defaultRouter = defaultRouter;
        s_automationLayer = IAutomationLayer(automationLayerAddress);
        s_acceptingNewRecurringBuys = true;
        i_wrapNative = _wrapNative;
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    /** @dev added nonReentrant and whenNotPaused third party modifiers. The amount input
     *  should not be 0 and it reverts if acceptingNewRecurringBuys storage variable is false. It
     *  also reverts if the address of any given token is address(0) and reverts if time interval
     *  is 0.
     *  @inheritdoc IDollarCostAverage
     */
    function createRecurringBuy(
        uint256 amountToSpend,
        address tokenToSpend,
        address tokenToBuy,
        uint256 timeIntervalInSeconds,
        address paymentInterface,
        address dexRouter
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();

        if (amountToSpend == 0) {
            revert DollarCostAverage__AmountIsZero();
        }
        if (!s_acceptingNewRecurringBuys) {
            revert DollarCostAverage__NotAcceptingNewRecurringBuys();
        }
        if (tokenToSpend == address(0) || tokenToBuy == address(0)) {
            revert DollarCostAverage__InvalidTokenAddresses();
        }
        if (timeIntervalInSeconds == 0) {
            revert DollarCostAverage__InvalidTimeInterval();
        }

        address router = dexRouter == address(0) ? s_defaultRouter : dexRouter;
        address[] memory path = __checkPairs(router, tokenToSpend, tokenToBuy);
        uint256 nextRecurringBuyId = s_nextRecurringBuyId;
        uint256 accountNumber = s_automationLayer.createAccount(
            nextRecurringBuyId,
            msg.sender,
            address(this)
        );

        RecurringBuy memory buy = RecurringBuy(
            msg.sender,
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            router,
            block.timestamp,
            accountNumber,
            path,
            Status.SET
        );

        s_recurringBuys[nextRecurringBuyId] = buy;
        unchecked {
            ++s_nextRecurringBuyId;
        }

        emit RecurringBuyCreated(nextRecurringBuyId, msg.sender, buy);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers. The given recurring buy ID
     *  must be valid. It reverts if caller is not recurring buy sender.
     *  @inheritdoc IDollarCostAverage
     */
    function cancelRecurringPayment(
        uint256 recurringBuyId
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();

        RecurringBuy storage buy = s_recurringBuys[recurringBuyId];

        if (buy.status != Status.SET) {
            revert DollarCostAverage__InvalidRecurringBuyId();
        }
        if (msg.sender != buy.sender) {
            revert DollarCostAverage__CallerNotRecurringBuySender();
        }

        buy.status = Status.CANCELLED;
        s_automationLayer.cancelAccount(buy.accountNumber);

        emit RecurringBuyCancelled(recurringBuyId, buy.sender);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers. The given recurring buy ID
     *  must be valid. It reverts if recurring buy is not valid, or if current block timestamp haven't reached
     *  payment due, or if ERC20 transferFrom function doesn't work.
     *  @inheritdoc IAutomatedContract
     */
    function trigger(
        uint256 recurringBuyId
    ) public override(IAutomatedContract) {
        __nonReentrant();
        __whenNotPaused();

        RecurringBuy storage buy = s_recurringBuys[recurringBuyId];
        if (buy.status != Status.SET || buy.paymentDue > block.timestamp) {
            revert DollarCostAverage__InvalidRecurringBuy();
        }

        __haveEnoughAllowance(buy.tokenToSpend, buy.sender, buy.amountToSpend);
        buy.paymentDue += buy.timeIntervalInSeconds;

        // calculating fees
        uint256 fee = (buy.amountToSpend * FEE) / PRECISION;
        uint256 contractFee = (fee * CONTRACT_FEE_SHARE) / PRECISION;
        uint256 buyAmount = buy.amountToSpend - fee;

        // payment interface fee
        if (buy.paymentInterface != address(0)) {
            __transferERC20(
                buy.tokenToSpend,
                buy.sender,
                buy.paymentInterface,
                fee - contractFee,
                true
            );
        }

        // protocol fee
        __transferERC20(
            buy.tokenToSpend,
            buy.sender,
            owner(),
            contractFee,
            true
        );

        // Transfering from user to this address and approving DEX router
        __transferERC20(
            buy.tokenToSpend,
            buy.sender,
            address(this),
            buyAmount,
            true
        );
        __approveERC20(buy.tokenToSpend, buy.dexRouter, buyAmount);

        // swap process
        IDEXRouter dexRouter = IDEXRouter(buy.dexRouter);
        uint256[] memory amountsOut = dexRouter.getAmountsOut(
            buyAmount,
            buy.path
        );
        uint256 amountOutMin = (amountsOut[amountsOut.length - 1] *
            SLIPPAGE_PERCENTAGE) / PRECISION;

        uint256[] memory amounts = dexRouter.swapExactTokensForTokens(
            buyAmount,
            amountOutMin,
            buy.path,
            buy.sender,
            block.timestamp
        );

        emit PaymentTransferred(recurringBuyId, buy.sender, amounts);
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IDollarCostAverage
     */
    function setAutomationLayer(
        address automationLayerAddress
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        if (automationLayerAddress == address(0)) {
            revert DollarCostAverage__InvalidAutomationLayerAddress();
        }

        s_automationLayer = IAutomationLayer(automationLayerAddress);

        emit AutomationLayerSet(msg.sender, automationLayerAddress);
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IDollarCostAverage
     */
    function setDefaultRouter(
        address defaultRouter
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        if (defaultRouter == address(0)) {
            revert DollarCostAverage__InvalidDefaultRouterAddress();
        }

        s_defaultRouter = defaultRouter;

        emit DefaultRouterSet(msg.sender, defaultRouter);
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IDollarCostAverage
     */
    function setAcceptingNewRecurringBuys(
        bool acceptingNewRecurringBuys
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_acceptingNewRecurringBuys = acceptingNewRecurringBuys;

        emit AcceptingRecurringBuysSet(msg.sender, acceptingNewRecurringBuys);
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IDollarCostAverage
    function getNextRecurringBuyId()
        external
        view
        override(IDollarCostAverage)
        returns (uint256)
    {
        return s_nextRecurringBuyId;
    }

    /// @inheritdoc IDollarCostAverage
    function getDefaultRouter()
        external
        view
        override(IDollarCostAverage)
        returns (address)
    {
        return s_defaultRouter;
    }

    /// @inheritdoc IDollarCostAverage
    function getAutomationLayer()
        external
        view
        override(IDollarCostAverage)
        returns (IAutomationLayer)
    {
        return s_automationLayer;
    }

    /// @inheritdoc IAutomatedContract
    function checkTrigger(
        uint256 recurringBuyId
    ) external view override(IAutomatedContract) returns (bool) {
        return isRecurringBuyValid(recurringBuyId);
    }

    /// @inheritdoc IDollarCostAverage
    function getCurrentBlockTimestamp()
        external
        view
        override(IDollarCostAverage)
        returns (uint256)
    {
        return block.timestamp;
    }

    /// @inheritdoc IDollarCostAverage
    function getRecurringBuy(
        uint256 recurringBuyId
    ) external view override(IDollarCostAverage) returns (RecurringBuy memory) {
        return s_recurringBuys[recurringBuyId];
    }

    /// @inheritdoc IDollarCostAverage
    function getAcceptingNewRecurringBuys()
        external
        view
        override(IDollarCostAverage)
        returns (bool)
    {
        return s_acceptingNewRecurringBuys;
    }

    /// @inheritdoc IDollarCostAverage
    function getWrapNative()
        external
        view
        override(IDollarCostAverage)
        returns (address)
    {
        return i_wrapNative;
    }

    /// @inheritdoc IDollarCostAverage
    function getRangeOfRecurringBuys(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        external
        view
        override(IDollarCostAverage)
        returns (RecurringBuy[] memory)
    {
        __validateIndexRange(startRecBuyId, endRecBuyId);

        uint256 forLoopEndRecBuyId = endRecBuyId + 1;

        RecurringBuy[] memory recurringBuys = new RecurringBuy[](
            forLoopEndRecBuyId - startRecBuyId
        );

        for (uint256 i = startRecBuyId; i < forLoopEndRecBuyId; ++i) {
            recurringBuys[i - startRecBuyId] = s_recurringBuys[i];
        }

        return recurringBuys;
    }

    /// @inheritdoc IDollarCostAverage
    function getValidRangeOfRecurringBuys(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        external
        view
        override(IDollarCostAverage)
        returns (RecurringBuy[] memory)
    {
        __validateIndexRange(startRecBuyId, endRecBuyId);

        uint256 forLoopEndRecBuyId = endRecBuyId + 1;

        RecurringBuy[] memory recurringBuys = new RecurringBuy[](
            forLoopEndRecBuyId - startRecBuyId
        );

        uint256 recBuyCount;
        for (uint256 i = startRecBuyId; i < forLoopEndRecBuyId; ++i) {
            recurringBuys[i - startRecBuyId] = s_recurringBuys[i];
            if (__validateRecurringBuy(recurringBuys[i - startRecBuyId])) {
                unchecked {
                    ++recBuyCount;
                }
            }
        }

        RecurringBuy[] memory validRecurringBuys = new RecurringBuy[](
            recBuyCount
        );
        uint256 index = 0;
        uint256 count = recurringBuys.length;
        for (uint256 i = 0; i < count; ++i) {
            if (__validateRecurringBuy(recurringBuys[i])) {
                validRecurringBuys[index++] = recurringBuys[i];
            }
        }

        return validRecurringBuys;
    }

    /// @inheritdoc IDollarCostAverage
    function isRecurringBuyValid(
        uint256 recurringBuyId
    ) public view override(IDollarCostAverage) returns (bool) {
        RecurringBuy memory buy = s_recurringBuys[recurringBuyId];
        return __validateRecurringBuy(buy);
    }

    /// -----------------------------------------------------------------------
    /// Internal/private view/pure functions
    /// -----------------------------------------------------------------------

    /** @dev Checks if given recurring buy ID is valid (with status == Status.SET).
     *  @param recBuy: recurring buy struct.
     */
    function __validateRecurringBuy(
        RecurringBuy memory recBuy
    ) private view returns (bool) {
        return
            recBuy.status == Status.SET && // 1. Has it been cancelled?
            !(recBuy.paymentDue > block.timestamp) && // 2. Has the time came to make the payment?
            !(IERC20(recBuy.tokenToSpend).balanceOf(recBuy.sender) <
                recBuy.amountToSpend) && // 3. Has the owner enough balance?
            !(IERC20(recBuy.tokenToSpend).allowance(
                recBuy.sender,
                address(this)
            ) < recBuy.amountToSpend); // 4. Has this smart contract enough allowance?
    }

    /** @dev checks the liquidity for given tokens.
     *  @param router: address of the DEX router.
     *  @param token1: ERC20 token address.
     *  @param token2: ERC20 token address.
     *  @return path address array for the right path of swap.
     */
    function __checkPairs(
        address router,
        address token1,
        address token2
    ) private view returns (address[] memory) {
        IDEXFactory factory = IDEXFactory(IDEXRouter(router).factory());

        if (factory.getPair(token1, token2) == address(0)) {
            address pair1AndWrapped = factory.getPair(token1, i_wrapNative);
            address pair2AndWrapped = factory.getPair(token2, i_wrapNative);

            if (
                pair1AndWrapped == address(0) || pair2AndWrapped == address(0)
            ) {
                revert DollarCostAverage__NoLiquidityPair();
            }

            address[] memory path = new address[](3);
            path[0] = token1;
            path[1] = i_wrapNative;
            path[2] = token2;

            return path;
        } else {
            address[] memory path = new address[](2);
            path[0] = token1;
            path[1] = token2;

            return path;
        }
    }
}
