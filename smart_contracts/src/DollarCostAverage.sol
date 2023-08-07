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
    uint256 private s_nextRecurringBuyId = 1;
    address private s_defaultRouter;
    IAutomationLayer private s_automationLayer;
    bool private s_acceptingNewRecurringBuys;
    address private immutable i_wrapNative;
    uint256 private s_fee = 100; // over 10000
    uint256 private s_contractFeeShare = 5000; // over 10000
    uint256 private s_slippagePercentage = 100; // over 10000
    address private s_duh;

    // mappings and arrays
    mapping(uint256 /* recurringBuyId */ => RecurringBuy /* data */)
        private s_recurringBuys;
    mapping(address /* sender */ => uint256[] /* ids */) private s_senderToIds;
    mapping(address /* ERC20 */ => bool /* isAllowed */)
        private s_allowedERC20s;

    // constants
    uint256 private constant PRECISION = 10000;

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
            startRecBuyId > endRecBuyId ||
            !(endRecBuyId < s_nextRecurringBuyId) ||
            startRecBuyId == 0 ||
            endRecBuyId == 0
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
     *  @param wrapNative: ERC20 smart contract address for the wrapped version of the native blockchain coin.
     *  @param duh: ERC20 smart contract address the DUH token.
     */
    constructor(
        address defaultRouter,
        address automationLayerAddress,
        address wrapNative,
        address duh
    ) Security(msg.sender) {
        if (defaultRouter == address(0)) {
            revert DollarCostAverage__InvalidDefaultRouterAddress();
        }

        s_defaultRouter = defaultRouter;
        s_automationLayer = IAutomationLayer(automationLayerAddress);
        s_acceptingNewRecurringBuys = true;
        i_wrapNative = wrapNative;
        s_duh = duh;
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
        if (
            !s_allowedERC20s[tokenToSpend] ||
            !s_allowedERC20s[tokenToBuy] ||
            tokenToSpend == tokenToBuy
        ) {
            revert DollarCostAverage__InvalidTokenAddresses();
        }
        if (timeIntervalInSeconds == 0) {
            revert DollarCostAverage__InvalidTimeInterval();
        }

        uint256[] storage recurringBuyIds = s_senderToIds[msg.sender];
        if (recurringBuyIds.length == 0) {
            recurringBuyIds.push(0);
        }

        address router = dexRouter == address(0) ? s_defaultRouter : dexRouter;
        address[] memory path = __checkPairs(router, tokenToSpend, tokenToBuy);
        uint256 nextRecurringBuyId = s_nextRecurringBuyId;

        recurringBuyIds.push(nextRecurringBuyId);
        RecurringBuy memory buy = RecurringBuy(
            msg.sender,
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            router,
            block.timestamp,
            0,
            path,
            recurringBuyIds.length - 1,
            Status.SET
        );

        unchecked {
            ++s_nextRecurringBuyId;
        }

        emit RecurringBuyCreated(nextRecurringBuyId, msg.sender);

        uint256 accountNumber = 0;
        if (address(s_automationLayer) != address(0)) {
            accountNumber = s_automationLayer.createAccount(
                nextRecurringBuyId,
                msg.sender,
                address(this)
            );
        }

        buy.accountNumber = accountNumber;
        s_recurringBuys[nextRecurringBuyId] = buy;
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

        // updating status
        buy.status = Status.CANCELLED;

        // removing the ID from the array
        uint256[] storage ids = s_senderToIds[msg.sender];
        uint256 indexToRemove = buy.index;
        uint256 lastId = ids[ids.length - 1];
        ids[indexToRemove] = lastId;
        s_recurringBuys[lastId].index = indexToRemove;
        ids.pop();

        emit RecurringBuyCancelled(recurringBuyId, buy.sender);

        // cancelling account on the automation contract
        if (address(s_automationLayer) != address(0)) {
            s_automationLayer.cancelAccount(buy.accountNumber);
        }
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

        // initial checks
        RecurringBuy storage buy = s_recurringBuys[recurringBuyId];
        if (buy.status != Status.SET || buy.paymentDue > block.timestamp) {
            revert DollarCostAverage__InvalidRecurringBuy();
        }

        __haveEnoughAllowance(buy.tokenToSpend, buy.sender, buy.amountToSpend);

        // updating payment due
        buy.paymentDue += buy.timeIntervalInSeconds;

        // calculating fees
        (
            uint256 paymentInterfaceFee,
            uint256 protocolFee,
            uint256 buyAmount
        ) = __calculateFees(buy.amountToSpend);

        // Transfering from user to this address
        __transferERC20(
            buy.tokenToSpend,
            buy.sender,
            address(this),
            buyAmount + protocolFee,
            true
        );

        // payment interface fee
        if (buy.paymentInterface != address(0)) {
            __transferERC20(
                buy.tokenToSpend,
                buy.sender,
                buy.paymentInterface,
                paymentInterfaceFee,
                true
            );
        }

        // automation node payment
        uint256 feeFromAutomationLayer = 0;
        if (address(s_automationLayer) != address(0)) {
            feeFromAutomationLayer = s_automationLayer.getAutomationFee();
        }
        if (msg.sender != buy.sender && feeFromAutomationLayer > 0) {
            // building path
            address[] memory pathPayment = __checkPairs(
                s_defaultRouter,
                buy.tokenToSpend,
                s_duh
            );

            // fees calculation
            uint256 automationFee = (protocolFee * feeFromAutomationLayer) /
                PRECISION;
            protocolFee -= automationFee;
            uint256 payment = __prospectPayment(automationFee, pathPayment);

            // swap process
            __approveERC20(buy.tokenToSpend, s_defaultRouter, payment);
            __swap(
                payment,
                payment,
                IDEXRouter(s_defaultRouter),
                pathPayment,
                msg.sender
            );
        }

        // protocol fee
        __transferERC20(
            buy.tokenToSpend,
            address(this),
            address(s_automationLayer) != address(0)
                ? address(s_automationLayer)
                : owner(),
            protocolFee,
            true
        );

        // approving DEX router
        __approveERC20(buy.tokenToSpend, buy.dexRouter, buyAmount);

        // swap process
        IDEXRouter dexRouter = IDEXRouter(buy.dexRouter);
        uint256[] memory amountsOut = dexRouter.getAmountsOut(
            buyAmount,
            buy.path
        );
        uint256[] memory amounts = __swap(
            buyAmount,
            amountsOut[amountsOut.length - 1],
            dexRouter,
            buy.path,
            buy.sender
        );

        emit PaymentTransferred(recurringBuyId, buy.sender, amounts);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only allowed addresses can call this function.
     *  @inheritdoc IDollarCostAverage
     */
    function setAutomationLayer(
        address automationLayerAddress
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_automationLayer = IAutomationLayer(automationLayerAddress);

        emit AutomationLayerSet(msg.sender, automationLayerAddress);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only allowed addresses can call this function.
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

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only allowed addresses can call this function.
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

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only allowed addresses can call this function.
     *  @inheritdoc IDollarCostAverage
     */
    function setFee(uint256 fee) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_fee = fee;

        emit FeeSet(msg.sender, fee);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only allowed addresses can call this function.
     *  @inheritdoc IDollarCostAverage
     */
    function setContractFeeShare(
        uint256 contractFeeShare
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_contractFeeShare = contractFeeShare;

        emit ContractFeeShareSet(msg.sender, contractFeeShare);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only allowed addresses can call this function.
     *  @inheritdoc IDollarCostAverage
     */
    function setSlippagePercentage(
        uint256 slippagePercentage
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_slippagePercentage = slippagePercentage;

        emit SlippagePercentageSet(msg.sender, slippagePercentage);
    }

    /** @dev Added nonReentrant and whenNotPaused third party modifiers. Only allowed callers
     *  can call this function.
     *  @inheritdoc IDollarCostAverage
     */
    function setDuh(address duh) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        if (duh == address(0)) {
            revert DollarCostAverage__InvalidTokenAddresses();
        }

        s_duh = duh;

        emit DuhTokenSet(msg.sender, duh);
    }

    /** @dev Added nonReentrant and whenNotPaused third party modifiers. Only allowed callers
     *  can call this function.
     *  @inheritdoc IDollarCostAverage
     */
    function setAllowedERC20s(
        address token,
        bool isAllowed
    ) external override(IDollarCostAverage) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        if (token == address(0)) {
            revert DollarCostAverage__InvalidTokenAddresses();
        }

        s_allowedERC20s[token] = isAllowed;
    }

    /// -----------------------------------------------------------------------
    /// Internal state-change functions
    /// -----------------------------------------------------------------------

    /** @dev performs the swap for the given path of tokens.
     *  @param buyAmount: amount left to buy.
     *  @param amountOut: expected amount out after swap.
     *  @param dexRouter: DEX router interface instance used to perform the swap.
     *  @param path: token addresses swap path.
     *  @param to: recipient address that will receive the swap output.
     *  @return uint256 array with the swap amounts.
     */
    function __swap(
        uint256 buyAmount,
        uint256 amountOut,
        IDEXRouter dexRouter,
        address[] memory path,
        address to
    ) private returns (uint256[] memory) {
        uint256 amountOutMin = (amountOut * s_slippagePercentage) / PRECISION;

        uint256[] memory amounts = dexRouter.swapExactTokensForTokens(
            buyAmount,
            amountOutMin,
            path,
            to,
            block.timestamp
        );

        return amounts;
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

        uint256 recBuyCount = 0;
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
    function getFee()
        external
        view
        override(IDollarCostAverage)
        returns (uint256)
    {
        return s_fee;
    }

    /// @inheritdoc IDollarCostAverage
    function getContractFeeShare()
        external
        view
        override(IDollarCostAverage)
        returns (uint256)
    {
        return s_contractFeeShare;
    }

    /// @inheritdoc IDollarCostAverage
    function getSlippagePercentage()
        external
        view
        override(IDollarCostAverage)
        returns (uint256)
    {
        return s_slippagePercentage;
    }

    /// @inheritdoc IDollarCostAverage
    function getDuh()
        external
        view
        override(IDollarCostAverage)
        returns (address)
    {
        return s_duh;
    }

    /// @inheritdoc IDollarCostAverage
    function getSenderToIds(
        address sender
    ) external view override(IDollarCostAverage) returns (uint256[] memory) {
        return s_senderToIds[sender];
    }

    /// @inheritdoc IDollarCostAverage
    function getAllowedERC20s(
        address token
    ) external view override(IDollarCostAverage) returns (bool) {
        return s_allowedERC20s[token];
    }

    /// @inheritdoc IDollarCostAverage
    function getRecurringBuyFromIds(
        uint256[] calldata recurringBuyIds
    )
        external
        view
        override(IDollarCostAverage)
        returns (RecurringBuy[] memory)
    {
        RecurringBuy[] memory recBuys = new RecurringBuy[](
            recurringBuyIds.length
        );
        for (uint256 ii = 0; ii < recurringBuyIds.length; ++ii) {
            recBuys[ii] = s_recurringBuys[recurringBuyIds[ii]];
        }

        return recBuys;
    }

    /// @inheritdoc IDollarCostAverage
    function isRecurringBuyValid(
        uint256 recurringBuyId
    ) public view override(IDollarCostAverage) returns (bool) {
        RecurringBuy memory buy = s_recurringBuys[recurringBuyId];
        return __validateRecurringBuy(buy);
    }

    /// @inheritdoc IAutomatedContract
    function prospectAutomationPayment(
        uint256 recurringBuyId
    ) external view override(IAutomatedContract) returns (uint256) {
        RecurringBuy memory buy = s_recurringBuys[recurringBuyId];

        (, uint256 protocolFee, ) = __calculateFees(buy.amountToSpend);
        address[] memory path = __checkPairs(
            s_defaultRouter,
            buy.tokenToSpend,
            s_duh
        );
        uint256 automationPayment = (protocolFee *
            s_automationLayer.getAutomationFee()) / PRECISION;

        uint256 payment = __prospectPayment(automationPayment, path);

        return payment;
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
            address wrapNative = i_wrapNative;
            address pair1AndWrapped = factory.getPair(token1, wrapNative);
            address pair2AndWrapped = factory.getPair(token2, wrapNative);

            if (
                pair1AndWrapped == address(0) || pair2AndWrapped == address(0)
            ) {
                revert DollarCostAverage__NoLiquidityPair();
            }

            address[] memory path = new address[](3);
            path[0] = token1;
            path[1] = wrapNative;
            path[2] = token2;

            return path;
        } else {
            address[] memory path = new address[](2);
            path[0] = token1;
            path[1] = token2;

            return path;
        }
    }

    /** @dev calculates the fees.
     *  @param amount: amount to be spend in the swap.
     *  @return paymentInterfaceFee uint256 value for the fee of the payment interface.
     *  @return protocolFee uint256 value for the protocol fee.
     *  @return buyAmount amount left to buy.
     */
    function __calculateFees(
        uint256 amount
    )
        private
        view
        returns (
            uint256 paymentInterfaceFee,
            uint256 protocolFee,
            uint256 buyAmount
        )
    {
        uint256 fee = (amount * s_fee) / PRECISION;
        protocolFee = (fee * s_contractFeeShare) / PRECISION;
        buyAmount = amount - fee;
        paymentInterfaceFee = fee - protocolFee;
    }

    function __prospectPayment(
        uint256 automationFee,
        address[] memory path
    ) private view returns (uint256) {
        IDEXRouter dexRouter = IDEXRouter(s_defaultRouter);
        uint256[] memory amountsOut = dexRouter.getAmountsOut(
            automationFee,
            path
        );

        return amountsOut[amountsOut.length - 1];
    }
}
