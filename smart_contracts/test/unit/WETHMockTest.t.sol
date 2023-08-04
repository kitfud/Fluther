// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title WETHMock smart contract unit test
 */

import {Test} from "forge-std/Test.sol";
import {WETHMock} from "../mocks/WETHMock.sol";

contract WETHMockTest is Test {
    /* solhint-disable */
    WETHMock weth;

    address public user = makeAddr("user");
    address public anotherUser = makeAddr("anotherUser");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        weth = new WETHMock();
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructor() public {
        assertEq(weth.name(), "WETH");
        assertEq(weth.symbol(), "WETH");
    }

    /// -----------------------------------------------------------------------
    /// Test for: mint
    /// -----------------------------------------------------------------------

    function testMintSuccess() public {
        uint256 balanceBefore = weth.balanceOf(anotherUser);
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        weth.mint(anotherUser, amountToMint);

        uint256 balanceAfter = weth.balanceOf(anotherUser);

        assertEq(balanceAfter, balanceBefore + amountToMint);
    }

    /// -----------------------------------------------------------------------
    /// Test for: burn
    /// -----------------------------------------------------------------------

    modifier mintWeth() {
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        weth.mint(anotherUser, amountToMint);
        _;
    }

    function testBurnSuccess() public mintWeth {
        uint256 balanceBefore = weth.balanceOf(anotherUser);
        uint256 amountToBurn = 0.5 ether;

        vm.prank(user);
        weth.burn(anotherUser, amountToBurn);

        uint256 balanceAfter = weth.balanceOf(anotherUser);

        assertEq(balanceAfter, balanceBefore - amountToBurn);
    }
}
