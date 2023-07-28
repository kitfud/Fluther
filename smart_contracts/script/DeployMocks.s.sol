// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
