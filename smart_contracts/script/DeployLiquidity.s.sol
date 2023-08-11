// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Liquidity} from "../src/Liquidity.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployLoquidity is Script {
    Liquidity public liquidity;
    HelperConfig public config;

    function run() public {
        config = new HelperConfig();
        (, , , , , , , , uint256 deployerKey) = config.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        liquidity = new Liquidity();
        vm.stopBroadcast();
    }
}
