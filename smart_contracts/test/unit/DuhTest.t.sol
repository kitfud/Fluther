// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Duh} from "../../src/Duh.sol";
import {Security} from "../../src/Security.sol";

contract DuhTest is Test {
    /* solhint-disable */
    Duh duh;

    address public user = makeAddr("user");
    address public anotherUser = makeAddr("anotherUser");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        vm.prank(user);
        duh = new Duh();
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructor() public {
        string memory name = "Duh token";
        string memory symbol = "DUH";

        assertTrue(duh.getAllowed(user));
        assertEq(duh.name(), name);
        assertEq(duh.symbol(), symbol);
    }

    /// -----------------------------------------------------------------------
    /// Test for: mint
    /// -----------------------------------------------------------------------

    function testMintSuccess() public {
        uint256 balanceBefore = duh.balanceOf(anotherUser);
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        duh.mint(anotherUser, amountToMint);

        uint256 balanceAfter = duh.balanceOf(anotherUser);

        assertEq(balanceAfter, balanceBefore + amountToMint);
    }

    function testMintRevertsIfCallerNotAllowed() public {
        uint256 amountToMint = 1 ether;

        vm.prank(anotherUser);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        duh.mint(anotherUser, amountToMint);
    }

    function testMintRevertsIfContractPaused() public {
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        duh.pause();

        vm.prank(anotherUser);
        vm.expectRevert("Pausable: paused");
        duh.mint(anotherUser, amountToMint);
    }

    /// -----------------------------------------------------------------------
    /// Test for: burn
    /// -----------------------------------------------------------------------

    modifier mintDuh() {
        uint256 amountToMint = 1 ether;

        vm.prank(user);
        duh.mint(anotherUser, amountToMint);
        _;
    }

    function testBurnSuccess() public mintDuh {
        uint256 balanceBefore = duh.balanceOf(anotherUser);
        uint256 amountToBurn = 1 ether;

        vm.prank(user);
        duh.burn(anotherUser, amountToBurn);

        uint256 balanceAfter = duh.balanceOf(anotherUser);

        assertEq(balanceAfter, balanceBefore - amountToBurn);
    }

    function testBurnRevertsIfCallerNotAllowed() public mintDuh {
        uint256 amountToBurn = 1 ether;

        vm.prank(anotherUser);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        duh.burn(anotherUser, amountToBurn);
    }

    function testBurnRevertsIfContractPaused() public mintDuh {
        uint256 amountToBurn = 1 ether;

        vm.prank(user);
        duh.pause();

        vm.prank(anotherUser);
        vm.expectRevert("Pausable: paused");
        duh.burn(anotherUser, amountToBurn);
    }
}
