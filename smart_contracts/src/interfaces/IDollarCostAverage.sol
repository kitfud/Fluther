// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha.
 *  @title Interface for the Dollar Cost Averaging (Fluther) smart contract.
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {IAutomationLayer} from "./IAutomationLayer.sol";

/// -----------------------------------------------------------------------
/// Interface
/// -----------------------------------------------------------------------

interface IDollarCostAverage {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev error for when given amount of tokens to spend is zero
    error DollarCostAverage__AmountIsZero();

    /// @dev error for when the contract is not accepting new recurring buys (i.e. s_acceptingNewRecurringBuys = false)
    error DollarCostAverage__NotAcceptingNewRecurringBuys();

    /// @dev error for when an invalid recurring buy ID is given
    error DollarCostAverage__InvalidRecurringBuyId();

    /// @dev error for when the function caller is not recurring buy sender/creator
    error DollarCostAverage__CallerNotRecurringBuySender();

    /// @dev error for when the recurring buy is not valid or not enough time has past
    error DollarCostAverage__InvalidRecurringBuy();

    /// @dev error for when an invalid range of recurring buy IDs is given
    error DollarCostAverage__InvalidIndexRange();

    /// @dev error for when any of the given token address is zero.
    error DollarCostAverage__InvalidTokenAddresses();

    /// @dev error for when any of the given time interval is zero.
    error DollarCostAverage__InvalidTimeInterval();

    /// @dev error for when given default DEX router address is address(0).
    error DollarCostAverage__InvalidDefaultRouterAddress();

    /// @dev error for when given automation layer address is address(0).
    error DollarCostAverage__InvalidAutomationLayerAddress();

    /// @dev error for when there is not enough allowance for the recurring buy.
    error DollarCostAverage__TokenNotEnoughAllowance();

    /// @dev error for when there is no liquidity pair for given ERC20 tokens.
    error DollarCostAverage__NoLiquidityPair();

    /// -----------------------------------------------------------------------
    /// Type declarations (structs and enums)
    /// -----------------------------------------------------------------------

    /** @dev defines the status of each recurring buys ID.
     *  @param UNSET: the recurring buy has not been set yet.
     *  @param SET: the recurring buy has already been set.
     *  @param CANCELLED: the recurring buy has been cancelled.
     */
    enum Status {
        UNSET,
        SET,
        CANCELLED
    }

    /** @dev struct that contains all the information for a recurring buy.
     *  @param sender: the address of the recurring buy sender.
     *  @param amountToSpend: amount of token to spend.
     *  @param tokenToSpend: address of the ERC20 token contract that will be spent (???).
     *  @param tokenToBuy: address of the ERC20 token contract that will be bought (???).
     *  @param timeIntervalInSeconds: time interval in seconds for the recurring buy.
     *  @param paymentInterface: address of the payment interface (???).
     *  @param dexRouter: address of the DEX through which the swap will be carried out.
     *  @param paymentDue: next payment due timestamp.
     *  @param accountNumber: number of the account in the automation layer smart contract.
     *  @param path: address array for the swap path.
     *  @param status: recurring buy status (UNSET, SET, or CANCELLED).
     */
    struct RecurringBuy {
        address sender;
        uint256 amountToSpend;
        address tokenToSpend;
        address tokenToBuy;
        uint256 timeIntervalInSeconds;
        address paymentInterface;
        address dexRouter;
        uint256 paymentDue;
        uint256 accountNumber;
        address[] path;
        Status status;
    }

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /** @dev event for when a new recurring buy is created.
     *  @param recBuyId: new recurring buy ID.
     *  @param sender: address of the recurring buy sender.
     *  @param buy: RecurringBuy struct with all the information of a recurring buy.
     */
    event RecurringBuyCreated(
        uint256 indexed recBuyId,
        address indexed sender,
        RecurringBuy buy
    );

    /** @dev event for when a recurring buy is cancelled.
     *  @param recBuyId: recurring buy ID.
     *  @param sender: address of the recurring buy sender.
     */
    event RecurringBuyCancelled(
        uint256 indexed recBuyId,
        address indexed sender
    );

    /** @dev event for when the payment of a recurring buy is transferred.
     *  @param recBuyId: recurring buy ID.
     *  @param sender: address of the recurring buy sender.
     *  @param amounts: array of the token amounts swaped.
     */
    event PaymentTransferred(
        uint256 indexed recBuyId,
        address indexed sender,
        uint256[] amounts
    );

    /** @dev event for when the a new automation layer contract is set.
     *  @param caller: caller's address.
     *  @param automationLayerAddress: address of the new automation layer.
     */
    event AutomationLayerSet(
        address indexed caller,
        address indexed automationLayerAddress
    );

    /** @dev event for when the a new default DEX router address is set.
     *  @param caller: caller's address.
     *  @param defaultRouter: address of the new default DEX router.
     */
    event DefaultRouterSet(
        address indexed caller,
        address indexed defaultRouter
    );

    /** @dev event for when the a new default DEX router address is set.
     *  @param caller: caller's address.
     *  @param acceptingRecurringBuys: true if accepting, false otherwise.
     */
    event AcceptingRecurringBuysSet(
        address indexed caller,
        bool acceptingRecurringBuys
    );

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    /** @notice creates a new recurring buy.
     *  @param amountToSpend: amount to be spent of token1 in the recurring buy.
     *  @param tokenToSpend: address of the ERC20 token contract that will be spent.
     *  @param tokenToBuy: address of the ERC20 token contract that will be bought.
     *  @param timeIntervalInSeconds: time interval in seconds for the recurring buy.
     *  @param paymentInterface: address of the payment interface (other applications).
     *  @param dexRouter: address of the DEX through which the swap will be carried out.
     */
    function createRecurringBuy(
        uint256 amountToSpend,
        address tokenToSpend,
        address tokenToBuy,
        uint256 timeIntervalInSeconds,
        address paymentInterface,
        address dexRouter
    ) external;

    /** @notice cancels a valid recurring buy.
     *  @param recurringBuyId: recurring buy ID.
     */
    function cancelRecurringPayment(uint256 recurringBuyId) external;

    /** @notice sets new automation layer address.
     *  @param automationLayerAddress: new automation layer smart contract address.
     */
    function setAutomationLayer(address automationLayerAddress) external;

    /** @notice sets new default DEX router to perform the recurring buy.
     *  @param defaultRouter: new default DEX smart contract address.
     */
    function setDefaultRouter(address defaultRouter) external;

    /** @notice sets new default DEX router to perform the recurring buy.
     *  @param acceptingNewRecurringBuys: true if accepting, false otherwise.
     */
    function setAcceptingNewRecurringBuys(
        bool acceptingNewRecurringBuys
    ) external;

    /** @notice gets the timestamp of the current block.
     *  @return uint256 value for the block timestamp.
     */
    function getCurrentBlockTimestamp() external view returns (uint256);

    /** @notice gets all the recurring buy information.
     *  @param recurringBuyId: recurring buy ID.
     *  @return RecurringBuy struct with all the recurring buy information.
     */
    function getRecurringBuy(
        uint256 recurringBuyId
    ) external view returns (RecurringBuy memory);

    /** @notice reads nextRecurringBuyId storage variable.
     *  @return uint256 value for the next recurring buy, i.e. total recurring buys.
     */
    function getNextRecurringBuyId() external view returns (uint256);

    /** @notice reads automationLayer storage variable.
     *  @return IAutomationLayer of the automation layer smart contract.
     */
    function getAutomationLayer() external view returns (IAutomationLayer);

    /** @notice reads the acceptingNewRecurringBuys storage variable.
     *  @return boolean value that indicates whether the contract is accepting new recurring buys (true) or not (false).
     */
    function getAcceptingNewRecurringBuys() external view returns (bool);

    /** @notice reads WMATIC constant variable.
     *  @return address for the WMATIC ERC20 smart contract.
     */
    function getWrapNative() external view returns (address);

    /** @notice gets an array of recurring buys from a starting to an ending recurring buy ID.
     *  @param startRecBuyId: start recurring buy ID.
     *  @param endRecBuyId: end recurring buy ID.
     *  @return array of recurring buy structs.
     */
    function getRangeOfRecurringBuys(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    ) external view returns (RecurringBuy[] memory);

    /** @notice reads the defaultRouter storage variable.
     *  @return address for the default DEX router.
     */
    function getDefaultRouter() external view returns (address);

    /** @notice gets valid recurring buys based on the given range of recurring buy IDs.
     *  @param startRecBuyId: start recurring buy ID.
     *  @param endRecBuyId: end recurring buy ID.
     *  @return array of valid recurring buy structs.
     */
    function getValidRangeOfRecurringBuys(
        uint256 startRecBuyId,
        uint256 endRecBuyId
    ) external view returns (RecurringBuy[] memory);

    /** @notice gets if given recurring buy ID is valid.
     *  @param recurringBuyId: ID of the recurring buy.
     *  @return bool that specifies if the recurring buy is valid (true) or not (false).
     */
    function isRecurringBuyValid(
        uint256 recurringBuyId
    ) external view returns (bool);
}
