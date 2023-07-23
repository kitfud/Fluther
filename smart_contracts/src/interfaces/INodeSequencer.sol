// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM)
 *  @title Node sequencer interface
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

interface INodeSequencer {
    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    function getCurrentNode() external view returns (address);

    function hasSufficientTokens() external view returns (bool);

    function getMinimumDuh() external view returns (uint256);
}
