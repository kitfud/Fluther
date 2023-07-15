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

interface Automate {
    function trigger(uint256 index) external;

    function checkTrigger(uint256 index) external view returns (bool);
}

interface sequencer {
    function getCurrentNode() external view returns (address);

    function hasSufficientTokens() external view returns (bool);

    function minimumDuh() external view returns (uint256);
}

contract AutomationLayer {
    struct Accounts {
        address account;
        bool cancelled;
    }

    Accounts[] public accounts;
    mapping(address => bool) public isNodeRegistered;
    mapping(address => uint256[]) public addressToIndices;

    address public owner;
    uint256 public totalAccounts;
    address public duh;
    uint256 public minimumDuh;
    address public sequencerAddress;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    uint256 public automationFee = 100;

    event AccountCreated(address indexed customer);
    event AccountCancelled(uint256 indexed index, address indexed account);
    event TransactionSuccess(uint256 indexed index);

    constructor() {
        owner = msg.sender;
        minimumDuh = 0;

        duh = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC on Polygon
        //duh = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH on Ethereum
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }
    // check to see if nodes have enough tokens to be valid nodes
    modifier hasSufficientTokens() {
        require(
            sequencer(sequencerAddress).hasSufficientTokens() == true,
            "Insufficient token balance."
        );
        _;
    }
    //Checks with sequencer to ensure nodes are taking turns
    modifier isCurrentNode() {
        require(
            tx.origin == sequencer(sequencerAddress).getCurrentNode(),
            "Not current node"
        );
        _;
    }

    //contracts call create account to register a new account to be automated
    function createAccount() external returns (uint256) {
        totalAccounts++;
        address _account = msg.sender;
        Accounts memory newAccount = Accounts(_account, false);
        accounts.push(newAccount);

        addressToIndices[_account].push(accounts.length - 1);

        emit AccountCreated(_account);
        return accounts.length - 1;
    }

    //If transaction is ready to be triggered, nodes call trigger function
    function trigger(uint256 index) external hasSufficientTokens isCurrentNode {
        require(index < totalAccounts, "Invalid account index");

        Accounts storage account = accounts[index];
        require(!account.cancelled, "The profile has been canceled.");

        emit TransactionSuccess(index);

        
            Automate(account.account).trigger(index);
        // Transfer the tokens
        /*  require(
            IERC20(duh).transferFrom(account.account, tx.origin, automationFee),
            "Fee transfer failed."
        );
        */
    }

    // check to se if tranaction is ready to be triggered
    function checkTrigger(uint256 index) external view returns (bool) {
        require(index < totalAccounts, "Invalid account index");

        Accounts storage account = accounts[index];
        return Automate(account.account).checkTrigger(index);
    }

    //Contracts call this function to cancel an account
    function cancelAccount(uint256 index) external {
        require(index < totalAccounts, "Invalid payment index");

        Accounts storage account = accounts[index];

        require(
            msg.sender == account.account,
            "Only account creator can cancel account"
        );

        account.cancelled = true;

        emit AccountCancelled(index, account.account);
    }

    //look up indices using contract address
    function getIndicesFromAddress(address accountAddress)
        external
        view
        returns (uint256[] memory)
    {
        return addressToIndices[accountAddress];
    }

    //check if account has been cancelled before calling trigger
    function isAccountCanceled(uint256 index) external view returns (bool) {
        require(index < totalAccounts, "Invalid account index");

        Accounts storage account = accounts[index];

        return account.cancelled;
    }
        function setSequencerAddress(address _sequencerAddress)
        external
        onlyOwner
    {
        sequencerAddress = _sequencerAddress;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");

        owner = newOwner;
    }
}
