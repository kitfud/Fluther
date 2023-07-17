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

import {IAutomationLayer} from "./interfaces/IAutomationLayer.sol";
import {INodeSequencer} from "./interfaces/INodeSequencer.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IDollarCostAveraging} from "./interfaces/IDollarCostAveraging.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract AutomationLayer is
    IAutomationLayer,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /* solhint-disable */
    // base types
    uint256 private nextAccountNumber;
    address private duh;
    uint256 private minimumDuh;
    address private sequencerAddress;
    uint256 private automationFee = 100;

    // mappings and arrays
    mapping(uint256 accountNumber => Accounts) private accounts;
    mapping(address => bool) private isNodeRegistered;

    // constants
    address private constant WMATIC =
        0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------------------

    // check to see if nodes have enough tokens to be valid nodes
    modifier hasSufficientTokens() {
        require(
            INodeSequencer(sequencerAddress).hasSufficientTokens() == true,
            "Insufficient token balance."
        );
        _;
    }
    //Checks with sequencer to ensure nodes are taking turns
    modifier isCurrentNode() {
        require(
            tx.origin == INodeSequencer(sequencerAddress).getCurrentNode(),
            "Not current node"
        );
        _;
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor() {
        minimumDuh = 0;

        duh = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC on Polygon
        //duh = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH on Ethereum
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    //contracts call create account to register a new account to be automated
    function createAccount(uint256 id) external returns (uint256) {
        uint256 accountNumber = nextAccountNumber;

        accounts[accountNumber] = Accounts(msg.sender, id, false);

        ++nextAccountNumber;

        emit AccountCreated(msg.sender);
        return accountNumber;
    }

    //Contracts call this function to cancel an account
    function cancelAccount(uint256 accountNumber) external {
        require(accountNumber < nextAccountNumber, "Invalid payment index");

        Accounts storage account = accounts[accountNumber];

        require(
            msg.sender == account.account,
            "Only account creator can cancel account"
        );

        account.cancelled = true;

        emit AccountCancelled(accountNumber, account.account);
    }

    //If transaction is ready to be triggered, nodes call trigger function
    function trigger(
        uint256 accountNumber
    ) external hasSufficientTokens isCurrentNode {
        require(accountNumber < nextAccountNumber, "Invalid account index");

        Accounts memory account = accounts[accountNumber];
        require(!account.cancelled, "The profile has been canceled.");

        emit TransactionSuccess(accountNumber);

        IDollarCostAveraging(account.account).trigger(account.id);
        // Transfer the tokens
        /*  require(
            IERC20(duh).transferFrom(account.account, tx.origin, automationFee),
            "Fee transfer failed."
        );
        */
    }

    function setSequencerAddress(address _sequencerAddress) external onlyOwner {
        sequencerAddress = _sequencerAddress;
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    // check to se if tranaction is ready to be triggered
    function checkTrigger(uint256 accountNumber) external view returns (bool) {
        require(accountNumber < nextAccountNumber, "Invalid account index");

        Accounts memory account = accounts[accountNumber];
        return IDollarCostAveraging(account.account).checkTrigger(account.id);
    }

    // //look up indices using contract address
    // function getIndicesFromAddress(
    //     address accountAddress
    // ) external view returns (uint256[] memory) {
    //     return addressToIndices[accountAddress];
    // }

    //check if account has been cancelled before calling trigger
    function isAccountCanceled(
        uint256 accountNumber
    ) external view returns (bool) {
        require(accountNumber < nextAccountNumber, "Invalid account index");

        Accounts storage account = accounts[accountNumber];

        return account.cancelled;
    }
}
