// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM)
 *  @title Uniswap V2 interface
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

interface IUniswapV2Router02 {
    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) external view returns (uint256[] memory amounts);
}
