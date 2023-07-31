// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title Interface for the automated smart contracts
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

/// -----------------------------------------------------------------------
/// Interface
/// -----------------------------------------------------------------------

interface IAutomatedContract {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------
    /// -----------------------------------------------------------------------
    /// Type declarations (structs and enums)
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    /** @notice triggers a recurring buy.
     *  @param id: recurring buy ID.
     */
    function trigger(uint256 id) external;

    /** @notice checks if a recurring buy is ready to be triggered.
     *  @param id: recurring buy ID.
     *  @return boolean value that specifies if the recurring buy is ready to be triggered (true) or not (false)
     */
    function checkTrigger(uint256 id) external view returns (bool);
}
