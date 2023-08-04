// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/** @author @EWCunha
 *  @title DollarCostAverage smart contract invariant (stateful) test handler - fails on revert
 */

import {Test, console} from "forge-std/Test.sol";
import {DollarCostAverage} from "../../../src/DollarCostAverage.sol";
import {AutomationLayer} from "../../../src/AutomationLayer.sol";
import {Deploy} from "../../../script/Deploy.s.sol";
import {HelperConfig} from "../../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DollarCostAverageFailOnRevertHandler is Test {
    /* solhint-disable */
    struct AddressesWithRecBuy {
        address[] senders;
        mapping(address => bool) addressAdded;
    }

    struct RecurringBuysCreated {
        uint256[] ids;
        mapping(uint256 => bool) idAdded;
    }

    DollarCostAverage dca;
    AddressesWithRecBuy addWthRecBuy;
    RecurringBuysCreated recBuysCreated;

    address weth;
    address uni;

    uint256 constant AMOUNT_TO_MINT = 10 ether;

    /* solhint-enable */

    constructor(DollarCostAverage dca_, address weth_, address uni_) {
        dca = dca_;
        weth = weth_;
        uni = uni_;
    }

    function createRecurringBuy(
        uint256 tokenSeed,
        uint256 amountToSpend,
        uint256 timeIntervalInSeconds,
        address paymentInterface
    ) public {
        amountToSpend = bound(amountToSpend, 1, AMOUNT_TO_MINT);
        timeIntervalInSeconds = bound(timeIntervalInSeconds, 1, 365 days);

        (address tokenToSpend, address tokenToBuy) = __getTokens(tokenSeed);

        vm.prank(msg.sender);
        dca.createRecurringBuy(
            amountToSpend,
            tokenToSpend,
            tokenToBuy,
            timeIntervalInSeconds,
            paymentInterface,
            address(0)
        );

        if (!addWthRecBuy.addressAdded[msg.sender]) {
            addWthRecBuy.addressAdded[msg.sender] = true;
            addWthRecBuy.senders.push(msg.sender);
        }

        uint256 recBuyId = dca.getNextRecurringBuyId() - 1;
        if (!recBuysCreated.idAdded[recBuyId]) {
            recBuysCreated.idAdded[recBuyId] = true;
            recBuysCreated.ids.push(recBuyId);
        }
    }

    function cancelRecurringPayment(uint256 recurringBuyIdSeed) public {
        (
            address sender,
            uint256 recurringBuyId,
            bool isValid
        ) = __getValidRecBuyData(recurringBuyIdSeed);
        if (!isValid) {
            return;
        }

        vm.prank(sender);
        dca.cancelRecurringPayment(recurringBuyId);
    }

    function trigger(uint256 recurringBuyIdSeed) public {
        (
            address sender,
            uint256 recurringBuyId,
            bool isValid
        ) = __getValidRecBuyData(recurringBuyIdSeed);
        if (!isValid) {
            return;
        }

        address tokenToSpend = dca.getRecurringBuy(recurringBuyId).tokenToSpend;
        // uint256 amountToSpend = dca
        //     .getRecurringBuy(recurringBuyId)
        //     .amountToSpend;
        uint256 paymentDue = dca.getRecurringBuy(recurringBuyId).paymentDue;

        if (paymentDue > block.timestamp) {
            return;
        }

        vm.startPrank(sender);
        ERC20Mock(tokenToSpend).mint(sender, AMOUNT_TO_MINT);
        ERC20Mock(tokenToSpend).approve(address(dca), type(uint256).max);
        dca.trigger(recurringBuyId);
        vm.stopPrank();
    }

    function setAllowed(address allowed, bool isAllowed) public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setAllowed(allowed, isAllowed);
    }

    function setAutomationLayer(address automationLayer) public {
        if (automationLayer == address(0)) {
            return;
        }
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setAutomationLayer(automationLayer);
    }

    function setDefaultRouter(address defaultRouter) public {
        if (defaultRouter == address(0)) {
            return;
        }
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setDefaultRouter(defaultRouter);
    }

    function setAcceptingNewRecurringBuys(
        bool acceptingNewRecurringBuys
    ) public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setAcceptingNewRecurringBuys(acceptingNewRecurringBuys);
    }

    function setFee(uint256 fee) public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setFee(fee);
    }

    function setContractFeeShare(uint256 contractFeeShare) public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setContractFeeShare(contractFeeShare);
    }

    function setSlippagePercentage(uint256 slippagePercentage) public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setSlippagePercentage(slippagePercentage);
    }

    function setDuh(address duh) public {
        if (duh == address(0)) {
            return;
        }
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.setDuh(duh);
    }

    function pause() public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.pause();
    }

    function unpause() public {
        if (!dca.getAllowed(msg.sender)) {
            return;
        }

        vm.prank(msg.sender);
        dca.unpause();
    }

    function __getValidRecBuyData(
        uint256 seed
    ) private view returns (address, uint256, bool) {
        uint256 recurringBuyId = __getRecBuyId(seed);

        address sender = dca.getRecurringBuy(recurringBuyId).sender;
        uint8 status = uint8(dca.getRecurringBuy(recurringBuyId).status);

        bool isValid = recurringBuyId != 0 && status == 1;

        return (sender, recurringBuyId, isValid);
    }

    function __getTokens(uint256 seed) private view returns (address, address) {
        if (seed % 2 == 0) {
            return (weth, uni);
        }
        return (uni, weth);
    }

    function __getSender(uint256 seed) private view returns (address) {
        if (addWthRecBuy.senders.length == 0) {
            return address(0);
        }
        return addWthRecBuy.senders[seed % addWthRecBuy.senders.length];
    }

    function __getRecBuyId(uint256 seed) private view returns (uint256) {
        if (recBuysCreated.ids.length == 0) {
            return 0;
        }
        return recBuysCreated.ids[seed % recBuysCreated.ids.length];
    }
}
