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
        if (!__isValidAccount(status)) {
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

        __performSimpleAutomation(accountNumber, true);
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

    /** @dev added nonReentrant and whenNotPaused third party modifiers. It reverts if
     *  node does not have enough DUH balance or if it is not an allowed node.
     *  @inheritdoc IAutomationLayer
     */
    function simpleAutomationBatch(
        uint256[] calldata accountNumbers
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __hasSufficientTokens();
        __isCurrentNode();

        bool[] memory success = new bool[](accountNumbers.length);
        for (uint256 ii = 0; ii < accountNumbers.length; ++ii) {
            success[ii] = __performSimpleAutomation(accountNumbers[ii], false);
        }

        emit BatchSimpleAutomationDone(msg.sender, accountNumbers, success);
    }

    /** @dev Added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
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

    /** @dev Added onlyOwner and nonReentrant third party modifiers. Calls third party pause internal function
     *  @inheritdoc IAutomationLayer
     */
    function pause() external override(IAutomationLayer) {
        __nonReentrant();

        __onlyOwner();

        _pause();
    }

    /** @dev Added onlyOwner and nonReentrant third party modifiers. Calls third party unpause internal function
     *  @inheritdoc IAutomationLayer
     */
    function unpause() external override(IAutomationLayer) {
        __nonReentrant();
        __onlyOwner();

        _unpause();
    }

    /** @dev Added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function setDuh(address duh) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_duh = duh;
    }

    /** @dev Added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function setMinimumDuh(
        uint256 minimumDuh
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_minimumDuh = minimumDuh;
    }

    /** @dev Added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
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

    /** @dev Added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
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

    /** @dev Added nonReentrant and whenNotPaused third party modifiers.
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

    /** @dev Added nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc IAutomationLayer
     */
    function setAcceptingNewAccounts(
        bool acceptingNewAccounts
    ) external override(IAutomationLayer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyOwner();

        s_acceptingNewAccounts = acceptingNewAccounts;
    }

    /// -----------------------------------------------------------------------
    /// Internal state-change functions
    /// -----------------------------------------------------------------------

    /** @dev performs simple automation process.
     *  @param accountNumber: number of account.
     *  @param revert_: true to revert, false otherwise.
     *  @return bool that specifies if it was successful (true) or not (false), if it does not revert.
     */
    function __performSimpleAutomation(
        uint256 accountNumber,
        bool revert_
    ) private returns (bool) {
        Account memory account = s_accounts[accountNumber];

        if (__isValidAccount(account.status)) {
            (bool success, ) = account.automatedContract.call(
                abi.encodeWithSelector(
                    IAutomatedContract(account.automatedContract)
                        .simpleAutomation
                        .selector,
                    account.id
                )
            );

            if (revert_ && !success) {
                revert AutomationLayer__SimpleAutomationFailed();
            }

            return success;
        }
        if (revert_) {
            revert AutomationLayer__InvalidAccountNumber();
        }
        return false;
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
            IAutomatedContract(account.automatedContract).checkSimpleAutomation(
                account.id
            );
    }

    /// @inheritdoc IAutomationLayer
    function getAccount(
        uint256 accountNumber
    ) external view override(IAutomationLayer) returns (Account memory) {
        return s_accounts[accountNumber];
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
    function getMinimumDuh()
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

    /// -----------------------------------------------------------------------
    /// Internal view functions
    /// -----------------------------------------------------------------------

    /** @dev checks if account is valid.
     *  @param status: status of account.
     *  @return bool true if account is valid, false otherwise.
     */
    function __isValidAccount(Status status) private pure returns (bool) {
        return status == Status.SET;
    }
}
