// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title DeployMock script unit test
 */

import {Test} from "forge-std/Test.sol";
import {DeployMocks} from "../../script/DeployMocks.s.sol";

contract DeployMocksTest is Test {
    /* solhint-disable */
    DeployMocks deployer;

    address public user = makeAddr("user");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        deployer = new DeployMocks();
    }

    /// -----------------------------------------------------------------------
    /// Test for: run
    /// -----------------------------------------------------------------------

    function testRun() public {
        deployer.run();

        address weth = address(deployer.weth());
        address uni = address(deployer.uni());
        address config = address(deployer.config());

        assertNotEq(weth, address(0));
        assertNotEq(uni, address(0));
        assertNotEq(config, address(0));
    }
}
