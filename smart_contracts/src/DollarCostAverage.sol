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

import {IDollarCostAveraging} from "./interfaces/IDollarCostAveraging.sol";
import {IAutomatedContract} from "./interfaces/IAutomatedContract.sol";
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
    IAutomatedContract,
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
    IAutomationLayer private s_automationLayer;
    bool private s_acceptingNewRecurringBuys;
    address private immutable wrapNative;

    // mappings and arrays
    mapping(uint256 recurringBuyId => RecurringBuy data)
        private s_recurringBuys;

    // constants
    uint256 private constant FEE = 100; // over 10000
    uint256 private constant PRECISION = 10000;
    uint256 private constant CLIENT_FEE_SHARE = 5000; // over 10000
    uint256 private SLIPPAGE_PERCENTAGE = 100; // over 10000

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers (or functions as modifiers)
    /// -----------------------------------------------------------------------

    /// @dev Uses the nonReentrant modifier. This way reduces smart contract size.
    function __nonReentrant() private nonReentrant {}

    /// @dev Uses the whenNotPaused modifier. This way reduces smart contract size.
    function __whenNotPaused() private view whenNotPaused {}

    /// @dev Uses the onlyOwner modifier. This way reduces smart contract size.
    function __onlyOwner() private view onlyOwner {}

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
    ) {
        s_defaultRouter = defaultRouter;
        s_automationLayer = IAutomationLayer(automationLayerAddress);
        s_acceptingNewRecurringBuys = true;
        wrapNative = _wrapNative;
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    /** @dev added nonReentrant and whenNotPaused third party modifiers. The amount input
     *  should not be 0 and it reverts if acceptingNewRecurringBuys storage variable is false.
     *  @inheritdoc IDollarCostAveraging
     */
    function createRecurringBuy(
        uint256 amountToSpend,
        address tokenToSpend,
        address tokenToBuy,
        uint256 timeIntervalInSeconds,
        address paymentInterface,
        address dexRouter
    ) external override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();

        if (amountToSpend == 0) {
            revert DollarCostAveraging__AmountIsZero();
        }
        if (!s_acceptingNewRecurringBuys) {
            revert DollarCostAveraging__NotAcceptingNewRecurringBuys();
        }
        if (tokenToSpend == address(0) || tokenToBuy == address(0)) {
            revert DollarCostAveraging__InvalidTokenAddresses();
        }
        if (timeIntervalInSeconds == 0) {
            revert DollarCostAveraging__InvalidTimeInterval();
        }

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
            dexRouter == address(0) ? s_defaultRouter : dexRouter,
            block.timestamp,
            accountNumber,
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
     *  @inheritdoc IDollarCostAveraging
     */
    function cancelRecurringPayment(
        uint256 recurringBuyId
    ) external override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();

        RecurringBuy storage buy = s_recurringBuys[recurringBuyId];

        if (buy.status != Status.SET) {
            revert DollarCostAveraging__InvalidRecurringBuyId();
        }
        if (msg.sender != buy.sender) {
            revert DollarCostAveraging__CallerNotRecurringBuySender();
        }

        buy.status = Status.CANCELLED;
        s_automationLayer.cancelAccount(buy.accountNumber);

        emit RecurringBuyCancelled(recurringBuyId, buy.sender);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers. The given recurring buy ID
     *  must be valid. It reverts if recurring buy is not valid, or if current block timestamp haven't reached
     *  payment due, or if ERC20 transferFrom function doesn't work.
     *  @inheritdoc IDollarCostAveraging
     */
    function transferFunds(
        uint256 recurringBuyId
    ) public override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();

        RecurringBuy storage buy = s_recurringBuys[recurringBuyId];
        if (buy.status != Status.SET || buy.paymentDue > block.timestamp) {
            revert DollarCostAveraging__InvalidRecurringBuy();
        }

        buy.paymentDue += buy.timeIntervalInSeconds;
        uint256 fee = (buy.amountToSpend * FEE) / PRECISION;
        uint256 buyAmount = buy.amountToSpend - fee;

        uint256 clientFee = (fee * CLIENT_FEE_SHARE) / PRECISION;
        uint256 contractFee = fee - clientFee;

        if (buy.paymentInterface != address(0)) {
            __transferERC20(
                buy.tokenToSpend,
                buy.sender,
                buy.paymentInterface,
                clientFee
            );
        }

        __transferERC20(buy.tokenToSpend, buy.sender, owner(), contractFee);
        IERC20(buy.tokenToSpend).approve(buy.dexRouter, buyAmount);

        address[] memory path;
        if (buy.tokenToSpend == wrapNative || buy.tokenToBuy == wrapNative) {
            path = new address[](2);
            path[0] = buy.tokenToSpend;
            path[1] = buy.tokenToBuy;
        } else {
            path = new address[](3);
            path[0] = buy.tokenToSpend;
            path[1] = wrapNative;
            path[2] = buy.tokenToBuy;
        }

        IUniswapV2Router02 dexRouter = IUniswapV2Router02(buy.dexRouter);
        uint256[] memory amountsOut = dexRouter.getAmountsOut(buyAmount, path);
        uint256 amountOutMin = (amountsOut[amountsOut.length - 1] *
            SLIPPAGE_PERCENTAGE) / PRECISION;

        dexRouter.swapExactTokensForTokens(
            buyAmount,
            amountOutMin,
            path,
            buy.sender,
            block.timestamp
        );

        emit PaymentTransferred(recurringBuyId, buy.sender);
    }

    /** @dev calls transferFunds public function
     *  @inheritdoc IAutomatedContract
     */
    function simpleAutomation(
        uint256 recurringBuyId
    ) external override(IAutomatedContract) {
        transferFunds(recurringBuyId);
    }

    /** @dev added onlyOwner third party modifier.
     *  @inheritdoc IDollarCostAveraging
     */
    function setAutomationLayer(
        address automationLayerAddress
    ) external override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_automationLayer = IAutomationLayer(automationLayerAddress);

        emit AutomationLayerSet(msg.sender, automationLayerAddress);
    }

    /** @dev added onlyOwner third party modifier.
     *  @inheritdoc IDollarCostAveraging
     */
    function setDefaultRouter(
        address defaultRouter
    ) external override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_defaultRouter = defaultRouter;

        emit DefaultRouterSet(msg.sender, defaultRouter);
    }

    /** @dev added onlyOwner third party modifier. Calls third party pause internal function
     *  @inheritdoc IDollarCostAveraging
     */
    function pause() external override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        _pause();
    }

    /** @dev added onlyOwner third party modifier. Calls third party unpause internal function
     *  @inheritdoc IDollarCostAveraging
     */
    function unpause() external override(IDollarCostAveraging) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        _unpause();
    }

    /// -----------------------------------------------------------------------
    /// Internal and private state-change functions
    /// -----------------------------------------------------------------------

    /** @dev Performs transfer of ERC20 tokens using transferFrom function. The way this function does the
     *  transfers is safer because it works when the ERC20 transferFrom returns or does not return any value.
     *  @dev It reverts if the transfer was not successful (i.e. reverted) or if returned value is false.
     *  @param token: ERC20 token smart contract address to transfer.
     *  @param from: address from which tokens will be transferred.
     *  @param to: address to which tokens will be transferred.
     *  @param value: amount of ERC20 tokens to transfer.
     */
    function __transferERC20(
        address token,
        address from,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20(token).transferFrom.selector,
                from,
                to,
                value
            )
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert DollarCostAveraging__TokenTransferFailed();
        }
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IAutomatedContract
    function checkSimpleAutomation(
        uint256 recurringBuyId
    ) external view override(IAutomatedContract) returns (bool) {
        RecurringBuy memory buy = s_recurringBuys[recurringBuyId];
        return buy.paymentDue < block.timestamp && buy.status == Status.SET;
    }

    /// @inheritdoc IDollarCostAveraging
    function getCurrentBlockTimestamp()
        external
        view
        override(IDollarCostAveraging)
        returns (uint256)
    {
        return block.timestamp;
    }

    /// @inheritdoc IDollarCostAveraging
    function getRecurringBuy(
        uint256 recurringBuyId
    )
        external
        view
        override(IDollarCostAveraging)
        returns (RecurringBuy memory)
    {
        return s_recurringBuys[recurringBuyId];
    }

    /// @inheritdoc IDollarCostAveraging
    function getNextRecurringBuyId()
        external
        view
        override(IDollarCostAveraging)
        returns (uint256)
    {
        return s_nextRecurringBuyId;
    }

    /// @inheritdoc IDollarCostAveraging
    function getAutomationLayer()
        external
        view
        override(IDollarCostAveraging)
        returns (IAutomationLayer)
    {
        return s_automationLayer;
    }

    /// @inheritdoc IDollarCostAveraging
    function getAcceptingNewRecurringBuys()
        external
        view
        override(IDollarCostAveraging)
        returns (bool)
    {
        return s_acceptingNewRecurringBuys;
    }

    /// @inheritdoc IDollarCostAveraging
    function getWrapNative()
        external
        view
        override(IDollarCostAveraging)
        returns (address)
    {
        return wrapNative;
    }

    /// @inheritdoc IDollarCostAveraging
    function getRangeOfRecurringBuys(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    )
        external
        view
        override(IDollarCostAveraging)
        returns (RecurringBuy[] memory)
    {
        if (
            !(startRecBuyId < endRecBuyId) &&
            !(endRecBuyId < s_nextRecurringBuyId)
        ) {
            revert DollarCostAveraging__InvalidIndexRange();
        }

        RecurringBuy[] memory recurringBuys = new RecurringBuy[](
            endRecBuyId - startRecBuyId
        );

        for (uint256 i = startRecBuyId; i < endRecBuyId; ++i) {
            recurringBuys[i - startRecBuyId] = s_recurringBuys[i];
        }

        return recurringBuys;
    }
}
