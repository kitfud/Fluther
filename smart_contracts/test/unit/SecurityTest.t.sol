// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Security} from "../../src/Security.sol";

contract SecurityTest is Test {
    /* solhint-disable */
    Security security;

    address public user = makeAddr("user");
    address public anotherUser = makeAddr("anotherUser");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Events to test
    /// -----------------------------------------------------------------------

    event CallerPermissionSet(
        address indexed allowed,
        address indexed caller,
        bool isAllowed
    );

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        security = new Security(user);
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructor() public {
        assertTrue(security.getAllowed(user));
        assertTrue(!security.getAllowed(anotherUser));
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAllowed
    /// -----------------------------------------------------------------------

    function testSetAllowedSuccess() public {
        bool allowedBefore = security.getAllowed(anotherUser);

        vm.prank(user);
        security.setAllowed(anotherUser, true);

        bool allowedAfter = security.getAllowed(anotherUser);

        vm.prank(user);
        security.setAllowed(anotherUser, false);

        bool allowedAfterAfter = security.getAllowed(anotherUser);

        assertTrue(!allowedBefore);
        assertTrue(allowedAfter);
        assertTrue(!allowedAfterAfter);
    }

    function testSetAllowedEvent() public {
        vm.prank(user);
        vm.expectEmit(true, true, false, true, address(security));
        emit CallerPermissionSet(anotherUser, user, true);
        security.setAllowed(anotherUser, true);
    }

    function testSetAllowedRevertsIfCallerNotAllowed() public {
        vm.prank(anotherUser);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        security.setAllowed(anotherUser, true);
    }

    function testSetAllowedRevertsIfContractPaused() public {
        vm.startPrank(user);
        security.pause();
        vm.expectRevert("Pausable: paused");
        security.setAllowed(anotherUser, true);
    }

    /// -----------------------------------------------------------------------
    /// Test for: pause
    /// -----------------------------------------------------------------------

    function testPause() public {
        bool pausedBefore = security.paused();

        vm.prank(user);
        security.pause();

        bool pausedAfter = security.paused();

        assertTrue(!pausedBefore);
        assertTrue(pausedAfter);
    }

    function testPauseRevertsIfCallerNotAllowed() public {
        vm.prank(anotherUser);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        security.pause();
    }

    /// -----------------------------------------------------------------------
    /// Test for: unpause
    /// -----------------------------------------------------------------------

    function testUnpause() public {
        vm.prank(user);
        security.pause();

        bool pausedBefore = security.paused();

        vm.prank(user);
        security.unpause();

        bool pausedAfter = security.paused();

        assertTrue(pausedBefore);
        assertTrue(!pausedAfter);
    }

    function testUnpauseRevertsIfCallerNotAllowed() public {
        vm.prank(user);
        security.pause();

        vm.prank(anotherUser);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        security.unpause();
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAllowed
    /// -----------------------------------------------------------------------

    function testGetAllowed() public {
        assertTrue(security.getAllowed(user));
        assertTrue(!security.getAllowed(anotherUser));
    }
}
