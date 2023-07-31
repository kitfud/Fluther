// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title Contract to add liquidity Uniswap V2
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {IDEXRouter} from "./interfaces/IDEXRouter.sol";
import {IDEXFactory} from "./interfaces/IDEXFactory.sol";
import {Security} from "./Security.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract Liquidity is Security {
    address public constant ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
    address public constant FACTORY =
        0x7E0987E5b3a30e3f2828572Bb659A548460a3003;

    event LiquidityAdded(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 amountAReturned,
        uint256 amountBReturned,
        uint256 liquidity
    );

    event LiquidityRemoved(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountAReturned,
        uint256 amountBReturned,
        uint256 liquidity
    );

    constructor() Security(msg.sender) {}

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external {
        __onlyAllowed();
        __whenNotPaused();
        __nonReentrant();

        __transferERC20(tokenA, msg.sender, address(this), amountA, true);
        __transferERC20(tokenB, msg.sender, address(this), amountB, true);

        __approveERC20(tokenA, ROUTER, amountA);
        __approveERC20(tokenB, ROUTER, amountB);

        (
            uint256 amountAReturned,
            uint256 amountBReturned,
            uint256 liquidity
        ) = IDEXRouter(ROUTER).addLiquidity(
                tokenA,
                tokenB,
                amountA,
                amountB,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit LiquidityAdded(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            amountAReturned,
            amountBReturned,
            liquidity
        );
    }

    function removeLiquidity(address tokenA, address tokenB) external {
        __onlyAllowed();
        __whenNotPaused();
        __nonReentrant();

        address pair = IDEXFactory(FACTORY).getPair(tokenA, tokenB);

        uint256 liquidity = IERC20(pair).balanceOf(address(this));

        __approveERC20(pair, ROUTER, liquidity);

        (uint256 amountAReturned, uint256 amountBReturned) = IDEXRouter(ROUTER)
            .removeLiquidity(
                tokenA,
                tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit LiquidityRemoved(
            msg.sender,
            tokenA,
            tokenB,
            amountAReturned,
            amountBReturned,
            liquidity
        );
    }
}
