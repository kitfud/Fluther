// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title Interface for the Dollar Cost Averaging (Fluther) smart contract
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

/// -----------------------------------------------------------------------
/// Interface
/// -----------------------------------------------------------------------

interface IDollarCostAveraging {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------
    /// -----------------------------------------------------------------------
    /// Type declarations (structs and enums)
    /// -----------------------------------------------------------------------

    enum Status {
        UNSET,
        SET,
        CANCELLED
    }

    struct RecurringBuys {
        address sender;
        address token1;
        address token2;
        uint256 amount;
        uint256 timeIntervalInSeconds;
        address paymentInterface;
        address dexRouter;
        uint256 paymentDue;
        Status status;
    }

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event RecurringBuyCreated(
        uint256 indexed recBuyId,
        uint256 indexed accountNumber,
        address indexed sender,
        RecurringBuys buy
    );
    event RecurringBuyCancelled(uint256 indexed index, address indexed sender);
    event PaymentTransferred(uint256 indexed index);

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    function trigger(uint256 index) external;

    function checkTrigger(uint256 index) external view returns (bool);
}
