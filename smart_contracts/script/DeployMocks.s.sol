// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
/** @author @EWCunha
 *  @title script to deploy mock smart contracts.
 */

<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
import {Script} from "forge-std/Script.sol";
import {WETHMock} from "../test/mocks/WETHMock.sol";
import {UNIMock} from "../test/mocks/UNIMock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMocks is Script {
    WETHMock public weth;
    UNIMock public uni;
    HelperConfig public config;

    function run() public {
        config = new HelperConfig();
        (, , , , , , , , uint256 deployerKey) = config.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        weth = new WETHMock();
        uni = new UNIMock();
        vm.stopBroadcast();
    }
}
