// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapMock {
    /* solhint-disable */
    uint256 private constant TOKENS_RATE = 110; // over 10000
    uint256 private constant PRECISION = 10000;

    /* solhint-enable */

    function getAmountsOut(
        uint256 buyAmount,
        address[] calldata path
    ) external pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](path.length);

        result[result.length - 1] = (buyAmount * TOKENS_RATE) / PRECISION;

        return result;
    }

    function swapExactTokensForTokens(
        uint256 buyAmount,
        uint256 amountOutMin,
        address[] calldata path,
        address sender,
        uint256 /* timestamp */
    ) external {
        address tokenToSpend = path[0];
        address tokenToBuy = path[path.length - 1];

        IERC20(tokenToSpend).transferFrom(sender, address(this), amountOutMin);
        IERC20(tokenToBuy).transferFrom(address(this), sender, buyAmount);
    }
}
