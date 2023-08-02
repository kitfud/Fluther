// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {UNIMock} from "../mocks/UNIMock.sol";

contract UNIMockTest is Test {
    /* solhint-disable */
    UNIMock uni;

    address public user = makeAddr("user");
    address public anotherUser = makeAddr("anotherUser");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        uni = new UNIMock();
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructor() public {
        assertEq(uni.name(), "UNI");
        assertEq(uni.symbol(), "UNI");
    }

    /// -----------------------------------------------------------------------
    /// Test for: mint
    /// -----------------------------------------------------------------------

    function testMintSuccess() public {
        uint256 balanceBefore = uni.balanceOf(anotherUser);
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        uni.mint(anotherUser, amountToMint);

        uint256 balanceAfter = uni.balanceOf(anotherUser);

        assertEq(balanceAfter, balanceBefore + amountToMint);
    }

    /// -----------------------------------------------------------------------
    /// Test for: burn
    /// -----------------------------------------------------------------------

    modifier mintUni() {
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        uni.mint(anotherUser, amountToMint);
        _;
    }

    function testBurnSuccess() public mintUni {
        uint256 balanceBefore = uni.balanceOf(anotherUser);
        uint256 amountToBurn = 0.5 ether;

        vm.prank(user);
        uni.burn(anotherUser, amountToBurn);

        uint256 balanceAfter = uni.balanceOf(anotherUser);

        assertEq(balanceAfter, balanceBefore - amountToBurn);
    }
}
