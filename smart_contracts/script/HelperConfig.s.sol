// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title script for configuring the default values depending on the network
 */

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {UniswapMock} from "../test/mocks/UniswapMock.sol";
import {DEXFactoryMock} from "../test/mocks/DEXFactoryMock.sol";

// import {DevOpsTools} from "@devops/DevOpsTools.sol";

contract HelperConfig is Script {
    /* solhint-disable */
    struct NetworkConfig {
        address wrapNative;
        address defaultRouter;
        address duhToken;
        uint256 minimumDuh;
        uint256 automationFee;
        address oracleAddress;
        address token1;
        address token2;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    uint256 public constant MINIMUM_DUH = 1 ether;
    uint256 public constant AUTOMATION_FEE = 100;
    address public constant ORACLE = address(0);
    uint256 public constant DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    constructor() {
        if (block.chainid == 11155111 || block.chainid == 59140) {
            activeNetworkConfig = getTestnetConfig();
        } else if (block.chainid == 1 || block.chainid == 137) {
            activeNetworkConfig = getMainnetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getMainnetConfig() internal view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                wrapNative: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
                defaultRouter: 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008,
                // duhToken: DevOpsTools.get_most_recent_deployment(
                //     "Duh",
                //     block.chainid
                // ),
                duhToken: address(0),
                minimumDuh: MINIMUM_DUH,
                automationFee: AUTOMATION_FEE,
                oracleAddress: ORACLE,
                token1: address(0),
                token2: address(0),
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getTestnetConfig() internal view returns (NetworkConfig memory) {
        address wrapNative = address(0);
        if (block.chainid == 11155111) {
            wrapNative = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; //0xD0dF82dE051244f04BfF3A8bB1f62E1cD39eED92
        } else if (block.chainid == 59140) {
            wrapNative = 0x2C1b868d6596a18e32E61B901E4060C872647b6C;
        }
        return
            NetworkConfig({
                wrapNative: wrapNative,
                defaultRouter: 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008,
                // duhToken: DevOpsTools.get_most_recent_deployment(
                //     "Duh",
                //     block.chainid
                // ),
                duhToken: 0xC981B922bD3A81362388F9f8b68e2e85F57b6FD2,
                minimumDuh: MINIMUM_DUH,
                automationFee: AUTOMATION_FEE,
                oracleAddress: ORACLE,
                // token1: DevOpsTools.get_most_recent_deployment(
                //     "WETHMock",
                //     block.chainid
                // ), // WETHMock
                token1: 0x87FF5ccd14Dc002903E5B274C0E569c7a215e5A1, //WETHMock
                // token2: DevOpsTools.get_most_recent_deployment(
                //     "UNIMock",
                //     block.chainid
                // ), // UNIMock
                token2: 0x6e4c13eD298b5Fcac70dc0F672f75aAeCca52768, //UNIMock
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getOrCreateAnvilConfig() internal returns (NetworkConfig memory) {
        if (activeNetworkConfig.wrapNative != address(0)) {
            return activeNetworkConfig;
        }

        // setup mocks
        vm.startBroadcast();
        ERC20Mock duh = new ERC20Mock();
        ERC20Mock wrapNative = new ERC20Mock();
        ERC20Mock token1 = new ERC20Mock();
        ERC20Mock token2 = new ERC20Mock();
        DEXFactoryMock factory = new DEXFactoryMock(
            address(token1),
            address(token2),
            address(wrapNative)
        );
        UniswapMock dexRouter = new UniswapMock(address(factory));
        vm.stopBroadcast();

        return
            NetworkConfig({
                wrapNative: address(wrapNative),
                defaultRouter: address(dexRouter),
                duhToken: address(duh),
                minimumDuh: MINIMUM_DUH,
                automationFee: AUTOMATION_FEE,
                oracleAddress: ORACLE,
                token1: address(token1),
                token2: address(token2),
                deployerKey: DEFAULT_ANVIL_KEY
            });
    }
}
