// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title Deploy script unit test
 */

import {Test} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";

contract DeployTest is Test {
    /* solhint-disable */
    Deploy deployer;

    address public user = makeAddr("user");

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        deployer = new Deploy();
    }

    /// -----------------------------------------------------------------------
    /// Test for: run
    /// -----------------------------------------------------------------------

    function testRun() public {
        deployer.run();

        address automation = address(deployer.automation());
        address dca = address(deployer.dca());
        address sequencer = address(deployer.sequencer());
        address config = address(deployer.config());
        address duh = address(deployer.duh());
        address token1 = deployer.token1();
        address token2 = deployer.token2();
        address defaultRouter = deployer.defaultRouter();
        uint256 timePeriodForNode = deployer.timePeriodForNode();

        // bool deployDuh = deployer.DEPLOY_DUH();
        // bool deployDca = deployer.DEPLOY_DCA();
        // bool deployAutomation = deployer.DEPLOY_AUTOMATION();
        // bool deploySequencer = deployer.DEPLOY_SEQUENCER();

        assertNotEq(automation, address(0));
        assertNotEq(dca, address(0));
        assertNotEq(sequencer, address(0));
        assertNotEq(config, address(0));
        assertNotEq(duh, address(0));
        assertNotEq(token1, address(0));
        assertNotEq(token2, address(0));
        assertNotEq(defaultRouter, address(0));
        assertNotEq(timePeriodForNode, 0);
    }
}
