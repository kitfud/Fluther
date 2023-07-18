// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM)
 *  @title Automation layer interface
 *  This code is proprietary and confidential. All rights reserved.
 *  Unauthorized copying of this file, via any medium is strictly prohibited.
 *  Proprietary code by Levi Webb
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

/// -----------------------------------------------------------------------
/// Interface
/// -----------------------------------------------------------------------

interface IAutomationLayer {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev error for when the caller is not allowed to call the function
    error AutomationLayer__NotAllowed();

    /// @dev error for when an invalid account number is provided
    error AutomationLayer__InvalidAccountNumber();

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

    struct Account {
        address user;
        address automatedContract;
        uint256 id;
        Status status;
    }

    /// -----------------------------------------------------------------------
    /// Events
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

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    function createAccount(
        uint256 id,
        address user,
        address contractAddress
    ) external returns (uint256);

    function cancelAccount(uint256 accountNumber) external;
}
