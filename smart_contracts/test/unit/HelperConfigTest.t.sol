// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title HelperConfig script unit test
 */

import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract DeployMocksTest is Test {
    /* solhint-disable */
    HelperConfig config;

    address public user = makeAddr("user");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        config = new HelperConfig();
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructor() public {
        (
            address wrapNative,
            address defaultRouter,
            address duhToken,
            uint256 minimumDuh,
            uint256 automationFee,
            address oracleAddress,
            address token1,
            address token2,
            uint256 deployerKey
        ) = config.activeNetworkConfig();

        assertNotEq(wrapNative, address(0));
        assertNotEq(defaultRouter, address(0));
        assertNotEq(duhToken, address(0));
        assertEq(minimumDuh, config.MINIMUM_DUH());
        assertEq(automationFee, config.AUTOMATION_FEE());
        assertEq(oracleAddress, config.ORACLE());
        if (block.chainid == 1 || block.chainid == 137) {
            assertEq(token1, address(0));
            assertEq(token2, address(0));
        } else {
            assertNotEq(token1, address(0));
            assertNotEq(token2, address(0));
        }
        if (
            block.chainid == 11155111 ||
            block.chainid == 1 ||
            block.chainid == 137
        ) {
            assertNotEq(deployerKey, config.DEFAULT_ANVIL_KEY());
        } else {
            assertEq(deployerKey, config.DEFAULT_ANVIL_KEY());
        }
    }
}
