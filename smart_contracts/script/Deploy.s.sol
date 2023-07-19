// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {AutomationLayer} from "../src/AutomationLayer.sol";
import {DollarCostAverage} from "../src/DollarCostAverage.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract Deploy is Script {
    AutomationLayer public automation;
    DollarCostAverage public dca;
    HelperConfig public config;
    address public token1;
    address public token2;

    function run()
        public
        returns (AutomationLayer, DollarCostAverage, address, address)
    {
        config = new HelperConfig();
        (
            address wrapNative,
            address defaultRouter,
            address duhToken,
            uint256 minimumDuh,
            address sequencerAddress,
            uint256 automationFee,
            address oracleAddress,
            address token1_,
            address token2_,
            uint256 deployerKey
        ) = config.activeNetworkConfig();

        token1 = token1_;
        token2 = token2_;

        vm.startBroadcast(deployerKey);
        automation = new AutomationLayer(
            duhToken,
            minimumDuh,
            sequencerAddress,
            automationFee,
            oracleAddress
        );

        dca = new DollarCostAverage(
            defaultRouter,
            address(automation),
            wrapNative
        );
        vm.stopBroadcast();

        return (automation, dca, token1, token2);
    }
}
