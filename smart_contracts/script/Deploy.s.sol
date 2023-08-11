// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
/** @author @EWCunha
 *  @title Script to deploy smart contracts
 */

<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
import {Script} from "forge-std/Script.sol";
import {AutomationLayer} from "../src/AutomationLayer.sol";
import {DollarCostAverage} from "../src/DollarCostAverage.sol";
import {NodeSequencer} from "../src/NodeSequencer.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Duh} from "../src/Duh.sol";

contract Deploy is Script {
<<<<<<< HEAD
<<<<<<< HEAD
    bool public constant DEPLOY_DUH = true;
    bool public constant DEPLOY_DCA = true;
    bool public constant DEPLOY_AUTOMATION = true;
    bool public constant DEPLOY_SEQUENCER = true;
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
    bool public constant DEPLOY_DUH = false;
    bool public constant DEPLOY_DCA = true;
    bool public constant DEPLOY_AUTOMATION = false;
    bool public constant DEPLOY_SEQUENCER = false;
<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

    AutomationLayer public automation;
    DollarCostAverage public dca;
    NodeSequencer public sequencer;
    HelperConfig public config;
    Duh public duh;
    address public token1;
    address public token2;
    address public defaultRouter;
    uint256 public timePeriodForNode;

    function run() public {
        config = new HelperConfig();
        (
            address wrapNative,
            address defaultRouter_,
            address duhToken,
            uint256 minimumDuh,
            uint256 automationFee,
            address oracleAddress,
            address token1_,
            address token2_,
            uint256 deployerKey
        ) = config.activeNetworkConfig();

        token1 = token1_;
        token2 = token2_;
        defaultRouter = defaultRouter_;
<<<<<<< HEAD
<<<<<<< HEAD
=======
        duh = Duh(duhToken);
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
        duh = Duh(duhToken);
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

        vm.startBroadcast(deployerKey);
        if (DEPLOY_DUH) {
            duh = new Duh();
<<<<<<< HEAD
<<<<<<< HEAD
=======
            duhToken = address(duh);
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
            duhToken = address(duh);
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
        }

        if (DEPLOY_AUTOMATION) {
            automation = new AutomationLayer(
<<<<<<< HEAD
<<<<<<< HEAD
                address(duh) == address(0) ? duhToken : address(duh),
=======
                duhToken,
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
                duhToken,
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
                minimumDuh,
                address(0),
                automationFee,
                oracleAddress
            );
        }

        if (DEPLOY_SEQUENCER) {
            timePeriodForNode = 1 days;
            sequencer = new NodeSequencer(
                timePeriodForNode,
                address(automation)
            );
            automation.setSequencerAddress(address(sequencer));
        }

        if (DEPLOY_DCA) {
            dca = new DollarCostAverage(
                defaultRouter,
                address(automation),
                wrapNative,
<<<<<<< HEAD
<<<<<<< HEAD
                address(duh) == address(0) ? duhToken : address(duh)
=======
                duhToken
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
                duhToken
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
            );
        }
        vm.stopBroadcast();
    }
}
