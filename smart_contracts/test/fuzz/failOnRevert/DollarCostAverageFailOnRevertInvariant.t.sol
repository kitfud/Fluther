// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/** @author @EWCunha
 *  @title DollarCostAverage smart contract invariant (stateful) test - fails on revert
 */

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DollarCostAverage} from "../../../src/DollarCostAverage.sol";
import {AutomationLayer} from "../../../src/AutomationLayer.sol";
import {Deploy} from "../../../script/Deploy.s.sol";
import {HelperConfig} from "../../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {DollarCostAverageFailOnRevertHandler} from "./DollarCostAverageFailOnRevertHandler.t.sol";

contract DollarCostAverageFailOnRevertInvariant is StdInvariant, Test {
    /* solhint-disable */
    Deploy deployer;
    DollarCostAverage dca;
    HelperConfig config;
    AutomationLayer automation;
    DollarCostAverageFailOnRevertHandler handler;

    address signer;
    ERC20Mock weth;
    ERC20Mock uni;
    address defaultRouter;
    address duhToken;

    uint256 constant AMOUNT_TO_MINT = 10 ether;
    uint256 constant AMOUNT_TO_MINT_SWAP = 1000 ether;

    function setUp() public {
        deployer = new Deploy();
        deployer.run();

        config = deployer.config();
        dca = deployer.dca();
        automation = deployer.automation();

        (
            ,
            address defRouter,
            ,
            ,
            ,
            ,
            address weth_,
            address uni_,
            uint256 deployerPk
        ) = config.activeNetworkConfig();
        signer = vm.addr(deployerPk);

        vm.startPrank(signer);
        automation.setSequencerAddress(address(0));
        dca.setAllowedERC20s(weth_, true);
        dca.setAllowedERC20s(uni_, true);
        vm.stopPrank();

        weth = ERC20Mock(weth_);
        uni = ERC20Mock(uni_);
        defaultRouter = defRouter;
        duhToken = address(deployer.duh());

        handler = new DollarCostAverageFailOnRevertHandler(
            dca,
            address(weth),
            address(uni)
        );

        weth.mint(defaultRouter, AMOUNT_TO_MINT_SWAP);
        uni.mint(defaultRouter, AMOUNT_TO_MINT_SWAP);

        excludeSender(signer);
        targetContract(address(handler));
    }

    function invariant_senderCannotSetAllowed() public {
        assertTrue(!dca.getAllowed(msg.sender));
    }

    function invariant_senderCannotPause() public {
        assertTrue(!dca.paused());
    }

    function invariant_senderCannotSetAutomationLayer() public {
        assertEq(address(dca.getAutomationLayer()), address(automation));
    }

    function invariant_senderCannotSetDefaultRouter() public {
        assertEq(dca.getDefaultRouter(), defaultRouter);
    }

    function invariant_senderCannotSetAcceptingNewRecurringBuys() public {
        assertTrue(dca.getAcceptingNewRecurringBuys());
    }

    function invariant_senderCannotSetFee() public {
        assertEq(dca.getFee(), 100);
    }

    function invariant_senderCannotSetContractFeeShare() public {
        assertEq(dca.getContractFeeShare(), 5000);
    }

    function invariant_senderCannotSetSlippagePercentage() public {
        assertEq(dca.getSlippagePercentage(), 100);
    }

    function invariant_senderCannotSetDuh() public {
        assertEq(dca.getDuh(), duhToken);
    }

    function invariant_senderCannotSetAllowedERC20s() public {
        assertTrue(dca.getAllowedERC20s(address(weth)));
        assertTrue(dca.getAllowedERC20s(address(uni)));
    }

    function invariant_contractBalanceShouldBe0() public {
        assertEq(weth.balanceOf(address(dca)), 0);
        assertEq(uni.balanceOf(address(dca)), 0);
        assertEq(ERC20Mock(duhToken).balanceOf(address(dca)), 0);
    }

    function invariant_getterFunctionsShouldNotRevert() public view {
        dca.getNextRecurringBuyId();
        dca.getDefaultRouter();
        dca.getAutomationLayer();
        dca.getCurrentBlockTimestamp();
        dca.getAcceptingNewRecurringBuys();
        dca.getWrapNative();
        dca.getFee();
        dca.getContractFeeShare();
        dca.getSlippagePercentage();
        dca.getDuh();
        dca.getSenderToIds(msg.sender);
        dca.getAllowedERC20s(msg.sender);
        dca.getRecurringBuysFromUser(msg.sender);
    }
}
