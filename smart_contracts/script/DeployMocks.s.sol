// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title script to deploy mock smart contracts.
 */

import {Script} from "forge-std/Script.sol";
import {WETHMock} from "../test/mocks/WETHMock.sol";
import {UNIMock} from "../test/mocks/UNIMock.sol";
import {DEXFactoryMock} from "../test/mocks/DEXFactoryMock.sol";
import {UniswapMock} from "../test/mocks/UniswapMock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMocks is Script {
    WETHMock public weth;
    UNIMock public uni;
    DEXFactoryMock public factory;
    UniswapMock public router;
    HelperConfig public config;

    function run() public {
        config = new HelperConfig();
        (address wrapNative, , , , , , , , uint256 deployerKey) = config
            .activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        weth = new WETHMock();
        uni = new UNIMock();
        if (block.chainid == 59140) {
            factory = new DEXFactoryMock(
                address(weth),
                address(uni),
                wrapNative
            );
            router = new UniswapMock(address(factory));
        }
        vm.stopBroadcast();
    }
}
