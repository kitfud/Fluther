// SPDX-License-Identifier: UNLICENSED
// This code is proprietary and confidential. All rights reserved.
// Proprietary code by Levi Webb

pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract NodeSequencer {
    address[] public registeredNodes;
    mapping(address => bool) public isNodeRegistered;

    address public owner;
    address public duh;
    uint256 public minimumDuh;
    uint256 public blockNumberRange;

    constructor() {
        owner = msg.sender;

        // Register msg.sender as a node
        registeredNodes.push(msg.sender);
        isNodeRegistered[msg.sender] = true;

        minimumDuh = 0;
        blockNumberRange = 1000;
        //duh = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC on Polygon
        duh = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH on Ethereum
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }

    function getBlockNumber() public view returns (uint256) {
        uint256 blockNumber = block.number;
        return (blockNumber);
    }

    function registerNode() external {
        require(!isNodeRegistered[tx.origin], "Node is already registered.");
        require(hasSufficientTokens() == true, "Insufficient duh balance");
        registeredNodes.push(tx.origin);
        isNodeRegistered[tx.origin] = true;
    }

    function updateMinimumDuh(uint256 _minimumDuh) external onlyOwner {
        minimumDuh = _minimumDuh;
    }

    function setDuhAddress(address tokenAddress) external onlyOwner {
        duh = tokenAddress;
    }

    function hasSufficientTokens() public view returns (bool) {
        return IERC20(duh).balanceOf(tx.origin) >= minimumDuh;
    }

    function setBlockNumberRange(uint256 _blockNumberRange) external onlyOwner {
        blockNumberRange = _blockNumberRange;
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


    function removeNode(uint256 index) external {
        bool validateNode = IERC20(duh).balanceOf(registeredNodes[index]) >=
            minimumDuh;
        require(validateNode == false, "node is valid");
        registeredNodes[index] = registeredNodes[registeredNodes.length - 1];

        // Decrease the length of the array
        registeredNodes.pop();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");

        owner = newOwner;
    }
}
