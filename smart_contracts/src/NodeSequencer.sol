// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM)
 *  @title Automation layer smart contract
 *  This code is proprietary and confidential. All rights reserved.
 *  Unauthorized copying of this file, via any medium is strictly prohibited.
 *  Proprietary code by Levi Webb
 */

// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {INodeSequencer} from "./interfaces/INodeSequencer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract NodeSequencer is INodeSequencer, Ownable, Pausable, ReentrancyGuard {
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    // base types
    address private duh;
    uint256 private minimumDuh;
    uint256 private blockNumberRange;

    // mappings and arrays
    address[] private registeredNodes;
    mapping(address => bool) private isNodeRegistered;

    /// -----------------------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor() {
        // Register msg.sender as a node
        registeredNodes.push(msg.sender);
        isNodeRegistered[msg.sender] = true;

        minimumDuh = 0;
        blockNumberRange = 1000;
        duh = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC on Polygon
        //duh = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH on Ethereum
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    function registerNode() external {
        require(!isNodeRegistered[tx.origin], "Node is already registered.");
        require(hasSufficientTokens() == true, "Insufficient duh balance");
        registeredNodes.push(tx.origin);
        isNodeRegistered[tx.origin] = true;
    }

    function removeNode(uint256 index) external {
        bool validateNode = IERC20(duh).balanceOf(registeredNodes[index]) >=
            minimumDuh;
        require(validateNode == false, "node is valid");
        registeredNodes[index] = registeredNodes[registeredNodes.length - 1];

        // Decrease the length of the array
        registeredNodes.pop();
    }

    function updateMinimumDuh(uint256 _minimumDuh) external onlyOwner {
        minimumDuh = _minimumDuh;
    }

    function setDuhAddress(address tokenAddress) external onlyOwner {
        duh = tokenAddress;
    }

    function setBlockNumberRange(uint256 _blockNumberRange) external onlyOwner {
        blockNumberRange = _blockNumberRange;
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    function getBlockNumber() public view returns (uint256) {
        uint256 blockNumber = block.number;
        return (blockNumber);
    }

    function hasSufficientTokens() public view returns (bool) {
        return IERC20(duh).balanceOf(tx.origin) >= minimumDuh;
    }

    function getCurrentNodeIndex() public view returns (uint256) {
        uint256 nodeIndex = ((getBlockNumber() / blockNumberRange) %
            getTotalNodes());
        return (nodeIndex);
    }

    function getCurrentNode() public view returns (address) {
        address currentNode = registeredNodes[getCurrentNodeIndex()];
        return (currentNode);
    }

    function getTotalNodes() public view returns (uint256) {
        uint256 totalNodes = registeredNodes.length;
        return (totalNodes);
    }

    function getMinimumDuh() external view returns (uint256) {
        return minimumDuh;
    }
}
