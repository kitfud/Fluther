// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM) and @EWCunha
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
    bool private s_acceptingNewAccounts;

    // mappings and arrays
    mapping(uint256 accountNumber => Account) private s_accounts;
    mapping(address => bool) private s_isNodeRegistered;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers (or functions as modifiers)
    /// -----------------------------------------------------------------------

    /// @dev Uses the nonReentrant modifier. This way reduces smart contract size.
    function __nonReentrant() private nonReentrant {}

    /// @dev Uses the whenNotPaused modifier. This way reduces smart contract size.
    function __whenNotPaused() private view whenNotPaused {}

    /// @dev Uses the onlyOwner modifier. This way reduces smart contract size.
    function __onlyOwner() private view onlyOwner {}

    /** @dev validates if a account is valid
     *  @param status: the status of the account
     */
    function __validateAccountNumber(Status status) private pure {
        if (status != Status.SET) {
            revert AutomationLayer__InvalidAccountNumber();
        }
    }

    /// @dev checks if caller is oracle.
    function __onlyOracle() private view {
        if (msg.sender != s_oracleAddress) {
            revert AutomationLayer__CallerNotOracle();
        }
    }

    /// @dev checks if node has sufficient DUH tokens.
    function __hasSufficientTokens() private view {
        if (!INodeSequencer(s_sequencerAddress).hasSufficientTokens()) {
            revert AutomationLayer__NotEnoughtTokens();
        }
    }

    /// @dev checks if transaction origin is from an allowed node.
    function __isCurrentNode() private view {
        if (tx.origin != INodeSequencer(s_sequencerAddress).getCurrentNode()) {
            revert AutomationLayer__OriginNotNode();
        }
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /** @notice constructor logic
     *  @param duh: ERC20 token used to automate contracts
     *  @param minimumDuh: minimum amount of DUH tokens to be able to automate the contract
     *  @param sequencerAddress: address of the node sequencer smart contract
     *  @param oracleAddress: address of the price feed oracle for the DUH token
     */
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
        s_acceptingNewAccounts = true;
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    /** @dev added nonReentrant and whenNotPaused third party modifiers. It reverts if
     *  acceptingNewAccounts storage variable is false.
     *  @inheritdoc IAutomationLayer
     */
    function createAccount(
        uint256 id,
        address user,
        address contractAddress
    ) external override(IAutomationLayer) returns (uint256) {
        __nonReentrant();
        __whenNotPaused();
        if (!s_acceptingNewAccounts) {
            revert AutomationLayer__NotAccpetingNewAccounts();
        }

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

    /** @dev added nonReentrant and whenNotPaused third party modifiers. It reverts if
     *  the given account number is not valid.
     *  @inheritdoc IAutomationLayer
     */
    function cancelAccount(
        uint256 accountNumber
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();

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

    /** @dev added nonReentrant and whenNotPaused third party modifiers. It reverts if
     *  node does not have enough DUH balance or if it is not an allowed node. It also reverts if
     *  given account number is not valid.
     *  @inheritdoc IAutomationLayer
     */
    function simpleAutomation(
        uint256 accountNumber
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __hasSufficientTokens();
        __isCurrentNode();

        Account memory account = s_accounts[accountNumber];

        __validateAccountNumber(account.status);

        IAutomatedContract(account.automatedContract).simpleAutomation(
            account.id
        );
        // Transfer the tokens
        /*  require(
            IERC20(duh).transferFrom(account.account, tx.origin, automationFee),
            "Fee transfer failed."
        );
        */

        emit TransactionSuccess(
            accountNumber,
            account.user,
            account.automatedContract
        );
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function withdraw(uint256 amount) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();
        amount;
        //transferFrom(address(this), owner, amount)

        emit Withdrawn(owner(), amount);
    }

    /** @dev added onlyOwner third party modifier. Calls third party pause internal function
     *  @inheritdoc IAutomationLayer
     */
    function pause() external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        _pause();
    }

    /** @dev added onlyOwner third party modifier. Calls third party unpause internal function
     *  @inheritdoc IAutomationLayer
     */
    function unpause() external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        _unpause();
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function setSequencerAddress(
        address sequencerAddress
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_sequencerAddress = sequencerAddress;

        emit SequencerAddressSet(msg.sender, sequencerAddress);
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function setOracleAddress(
        address oracleAddress
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_oracleAddress = oracleAddress;

        emit OracleAddressSet(msg.sender, oracleAddress);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only oracle contract can call this function.
     *  @inheritdoc IAutomationLayer
     */
    function setAutomationFee(
        uint256 automationFee
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOracle();

        s_automationFee = automationFee;

        emit AutomationFeeSet(msg.sender, automationFee);
    }

    /** @dev added nonReentrant and whenNotPaused third party modifiers.
     *  Only oracle contract can call this function.
     *  @inheritdoc IAutomationLayer
     */
    function setAcceptingNewAccounts(
        bool acceptingNewAccounts
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOracle();

        s_acceptingNewAccounts = acceptingNewAccounts;
    }

    /** @dev added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function setNode(address node, bool isNodeRegistered) external {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_isNodeRegistered[node] = isNodeRegistered;

        emit NodeSet(msg.sender, node, isNodeRegistered);
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IAutomationLayer
    function checkSimpleAutomation(
        uint256 accountNumber
    ) external view override(IAutomationLayer) returns (bool) {
        Account memory account = s_accounts[accountNumber];

        __validateAccountNumber(account.status);

        return
            IAutomatedContract(account.automatedContract).checkSimpleAutomation(account.id);
    }

    /// @inheritdoc IAutomationLayer
    function getAccount(
        uint256 accountNumber
    ) external view override(IAutomationLayer) returns (Account memory) {
        return s_accounts[accountNumber];
    }

    /// @inheritdoc IAutomationLayer
    function getIsNodeRegistered(
        address node
    ) external view override(IAutomationLayer) returns (bool) {
        return s_isNodeRegistered[node];
    }

    /// @inheritdoc IAutomationLayer
    function getNextAccountNumber()
        external
        view
        override(IAutomationLayer)
        returns (uint256)
    {
        return s_nextAccountNumber;
    }

    /// @inheritdoc IAutomationLayer
    function getDuh()
        external
        view
        override(IAutomationLayer)
        returns (address)
    {
        return s_duh;
    }

    /// @inheritdoc IAutomationLayer
    function getMinimumDug()
        external
        view
        override(IAutomationLayer)
        returns (uint256)
    {
        return s_minimumDuh;
    }

    /// @inheritdoc IAutomationLayer
    function getSequencerAddress()
        external
        view
        override(IAutomationLayer)
        returns (address)
    {
        return s_sequencerAddress;
    }

    /// @inheritdoc IAutomationLayer
    function getAutomationFee()
        external
        view
        override(IAutomationLayer)
        returns (uint256)
    {
        return s_automationFee;
    }

    /// @inheritdoc IAutomationLayer
    function getOracleAddress()
        external
        view
        override(IAutomationLayer)
        returns (address)
    {
        return s_oracleAddress;
    }

    /// @inheritdoc IAutomationLayer
    function getAcceptingNewAccounts()
        external
        view
        override(IAutomationLayer)
        returns (bool)
    {
        return s_acceptingNewAccounts;
    }
}
