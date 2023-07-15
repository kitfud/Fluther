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
    /// -----------------------------------------------------------------------
    /// Type declarations (structs and enums)
    /// -----------------------------------------------------------------------

    struct Accounts {
        address account;
        uint256 id;
        bool cancelled;
    }

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event AccountCreated(address indexed customer);
    event AccountCancelled(uint256 indexed index, address indexed account);
    event TransactionSuccess(uint256 indexed index);

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    function createAccount(uint256 id) external returns (uint256);
}
