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
import {IAutomatedContract} from "./interfaces/IAutomatedContract.sol";
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
    uint256 private s_nextAccountNumber;
    address private s_duh;
    uint256 private s_minimumDuh;
    address private s_sequencerAddress;
    uint256 private s_automationFee;
    address private s_oracleAddress;

    // mappings and arrays
    mapping(uint256 accountNumber => Account) private s_accounts;
    mapping(address => bool) private s_isNodeRegistered;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers (or functions as modifiers)
    /// -----------------------------------------------------------------------

    function __validateAccountNumber(Status status) private pure {
        if (status != Status.SET) {
            revert AutomationLayer__InvalidAccountNumber();
        }
    }

    function __onlyOracle() private view {
        require(msg.sender == s_oracleAddress);
    }

    // check to see if nodes have enough tokens to be valid nodes
    modifier hasSufficientTokens() {
        require(
            INodeSequencer(s_sequencerAddress).hasSufficientTokens() == true,
            "Insufficient token balance."
        );
        _;
    }
    //Checks with sequencer to ensure nodes are taking turns
    modifier isCurrentNode() {
        require(
            tx.origin == INodeSequencer(s_sequencerAddress).getCurrentNode(),
            "Not current node"
        );
        _;
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        address duh,
        uint256 minimumDuh,
        address sequencerAddress,
        uint256 automationFee,
        address oracleAddress
    ) {
        s_duh = duh;
        s_minimumDuh = minimumDuh;
        s_sequencerAddress = sequencerAddress;
        s_automationFee = automationFee;
        s_oracleAddress = oracleAddress;
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    //contracts call create account to register a new account to be automated
    function createAccount(
        uint256 id,
        address user,
        address contractAddress
    ) external returns (uint256) {
        uint256 accountNumber = s_nextAccountNumber;

        s_accounts[accountNumber] = Account(
            user,
            contractAddress,
            id,
            Status.SET
        );

        unchecked {
            ++s_nextAccountNumber;
        }

        emit AccountCreated(user, contractAddress, id);

        return accountNumber;
    }

    //Contracts call this function to cancel an account
    function cancelAccount(uint256 accountNumber) external {
        Account storage account = s_accounts[accountNumber];

        __validateAccountNumber(account.status);

        if (
            msg.sender != account.user &&
            msg.sender != account.automatedContract
        ) {
            revert AutomationLayer__NotAllowed();
        }

        account.status = Status.CANCELLED;

        emit AccountCancelled(
            accountNumber,
            account.user,
            account.automatedContract
        );
    }

    //If transaction is ready to be triggered, nodes call trigger function
    function simpleAutomation(
        uint256 accountNumber
    ) external hasSufficientTokens isCurrentNode {
        Account memory account = s_accounts[accountNumber];

        __validateAccountNumber(account.status);

        emit TransactionSuccess(
            accountNumber,
            account.user,
            account.automatedContract
        );

        IAutomatedContract(account.automatedContract).simpleAutomation(
            account.id
        );
        // Transfer the tokens
        /*  require(
            IERC20(duh).transferFrom(account.account, tx.origin, automationFee),
            "Fee transfer failed."
        );
        */
    }

    // FOR SECURITY REASONS
    function withdraw(uint256 amount) external onlyOwner {
        //transferFrom(address(this), owner, amount)
    }

    function setSequencerAddress(address _sequencerAddress) external onlyOwner {
        s_sequencerAddress = _sequencerAddress;
    }

    function setOracleAddress(address _oracleAddress) external onlyOwner {
        s_oracleAddress = _oracleAddress;
    }

    function setAutomationFee(uint256 _automationFee) external {
        __onlyOracle();

        s_automationFee = _automationFee;
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    // check to se if tranaction is ready to be triggered
    function checkSimpleAutomation(
        uint256 accountNumber
    ) external view returns (bool) {
        Account memory account = s_accounts[accountNumber];

        __validateAccountNumber(account.status);

        return
            IAutomatedContract(account.user).checkSimpleAutomation(account.id);
    }

    function getAccount(
        uint256 accountNumber
    ) external view returns (Account memory) {
        return s_accounts[accountNumber];
    }
}
