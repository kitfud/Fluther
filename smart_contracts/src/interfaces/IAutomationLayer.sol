// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM) and @EWCunha
 *  @title Automation layer interface
 *  This code is proprietary and confidential. All rights reserved.
 *  Unauthorized copying of this file, via any medium is strictly prohibited.
 *  Proprietary code by Levi Webb
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

/// -----------------------------------------------------------------------
/// Interface
/// -----------------------------------------------------------------------

interface IAutomationLayer {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev error for when the caller is not allowed to call the function
    error AutomationLayer__NotAllowed();

    /// @dev error for when an invalid account number is provided
    error AutomationLayer__InvalidAccountNumber();

    /// @dev error for when the caller is not the oracle contract.
    error AutomationLayer__CallerNotOracle();

    /// @dev error for when node does not have enough tokens to trigger an operation.
    error AutomationLayer__NotEnoughtTokens();

    /// @dev error for when the origin of the transaction is not an allowed node.
    error AutomationLayer__OriginNotNode();

    /// @dev error for when the contract is not accepting the creation of new accounts.
    error AutomationLayer__NotAccpetingNewAccounts();

    /// -----------------------------------------------------------------------
    /// Type declarations (structs and enums)
    /// -----------------------------------------------------------------------

    /** @dev defines the status of each recurring buys ID.
     *  @param UNSET: the recurring buy has not been set yet.
     *  @param SET: the recurring buy has already been set.
     *  @param CANCELLED: the recurring buy has been cancelled.
     */
    enum Status {
        UNSET,
        SET,
        CANCELLED
    }

    /** @dev struct with all the Account info needed to operate the automations.
     *  @param user: address of the user that will have his operation automated.
     *  @param automatedContract: address of the smart contract to automate.
     *  @param id: id of the operation to automate.
     *  @param status: status of the account.
     */
    struct Account {
        address user;
        address automatedContract;
        uint256 id;
        Status status;
    }

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /** @dev event for when a new account is created
     *  @param user: address of the user that will have his operation automated.
     *  @param automatedContract: address of the smart contract to automate.
     *  @param id: id of the operation to automate.
     */
    event AccountCreated(
        address indexed user,
        address indexed automatedContract,
        uint256 id
    );

    /** @dev event for when an account is cancelled
     *  @param accountNumber: number of the account cancelled.
     *  @param user: address of the user.
     *  @param automatedContract: address of the smart contract.
     */
    event AccountCancelled(
        uint256 indexed accountNumber,
        address indexed user,
        address indexed automatedContract
    );

    /** @dev event for when the transaction is performed in a automated process.
     *  @param accountNumber: number of the account with the automation operation.
     *  @param user: user address.
     *  @param automatedContract: smart contract address that had a operation automated.
     */
    event TransactionSuccess(
        uint256 indexed accountNumber,
        address indexed user,
        address indexed automatedContract
    );

    /** @dev event for when a withdraw is made.
     *  @param to: withdraw recipient address.
     *  @param amount: amount withdrawn.
     */
    event Withdrawn(address indexed to, uint256 amount);

    /** @dev event for when a new node sequencer address is set.
     *  @param caller: address of the function caller.
     *  @param sequencer: new node sequencer address.
     */
    event SequencerAddressSet(
        address indexed caller,
        address indexed sequencer
    );

    /** @dev event for when a new oracle address is set.
     *  @param caller: address of the function caller.
     *  @param oracle: new oracle address.
     */
    event OracleAddressSet(address indexed caller, address indexed oracle);

    /** @dev event for when a new automation fee is set.
     *  @param caller: address of the function caller.
     *  @param automationFee: new value for the automation fee.
     */
    event AutomationFeeSet(address indexed caller, uint256 automationFee);

    /** @dev event for when a new value for acceptingNewAccounts is set.
     *  @param caller: address of the function caller.
     *  @param acceptingNewAccounts: new value for the acceptingNewAccounts.
     */
    event AcceptingAccountsSet(
        address indexed caller,
        bool acceptingNewAccounts
    );

    /** @dev event for when a new node is set.
     *  @param caller: address of the function caller.
     *  @param node: node address.
     *  @param isNodeRegistered: value that specifies if node is registered (true) or not (false).
     */
    event NodeSet(
        address indexed caller,
        address indexed node,
        bool isNodeRegistered
    );

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    /** @notice creates a new account to automate an operation.
     *  @param id: id of the operation. This id comes from the smart contract that will be automated,
     *  specified by the contractAddress parameter.
     *  @param user: address of the user that will have his operation automated.
     *  @param contractAddress: address of the smart contract to automate.
     */
    function createAccount(
        uint256 id,
        address user,
        address contractAddress
    ) external returns (uint256);

    /** @notice cancels an account.
     *  @param accountNumber: number of the account to cancel.
     */
    function cancelAccount(uint256 accountNumber) external;

    /** @notice triggers a simple automation operation.
     *  @param accountNumber: number of the account.
     */
    function simpleAutomation(uint256 accountNumber) external;

    /** @notice withdraws the given amount to owner account.
     *  @param amount: amount to withdraw.
     */
    function withdraw(uint256 amount) external;

    /** @notice pauses the smart contract so that any function won't work. */
    function pause() external;

    /** @notice unpauses the smart contract so that every function will work. */
    function unpause() external;

    /** @notice sets a new node sequencer address.
     *  @param sequencerAddress: address of the node sequencer.
     */
    function setSequencerAddress(address sequencerAddress) external;

    /** @notice sets a new oracle address.
     *  @param oracleAddress: address of the oracle.
     */
    function setOracleAddress(address oracleAddress) external;

    /** @notice sets a new automation fee.
     *  @param automationFee: value for the new automation fee.
     */
    function setAutomationFee(uint256 automationFee) external;

    /** @notice sets new value for the acceptingNewAccounts storage variable.
     *  @param acceptingNewAccounts: value for the new acceptingNewAccounts.
     *  If true, this means that it is allowed to create new accounts, false otherwise.
     */
    function setAcceptingNewAccounts(bool acceptingNewAccounts) external;

    /** @notice sets registry for given node address.
     *  @param node: address of the node.
     *  @param isNodeRegistered: true to set node as registered, false otherwise.
     */
    function setNode(address node, bool isNodeRegistered) external;

    /** @notice checks if given account number has an operation that can be triggered.
     *  @param accountNumber: number of the account.
     */
    function checkSimpleAutomation(
        uint256 accountNumber
    ) external view returns (bool);

    /** @notice reads an entry of the accounts storage mapping.
     *  @param accountNumber: number of the account.
     *  @return Account struct with the account information.
     */
    function getAccount(
        uint256 accountNumber
    ) external view returns (Account memory);

    /** @notice gets if the given node address is registered in the automaiton contract.
     *  @param node: node address.
     *  @return bool that specifies if given address is a registered node (true) or not (false).
     */
    function getIsNodeRegistered(address node) external view returns (bool);

    /** @notice reads nextAccountNumber storage variable.
     *  @return uint256 current value of the nextAccountNumber storage variable.
     */
    function getNextAccountNumber() external view returns (uint256);

    /** @notice reads duh storage variable.
     *  @return address for the duh ERC20 smart contract.
     */
    function getDuh() external view returns (address);

    /** @notice reads the minimumDuh storage variable.
     *  @return uint256 value for the current minimumDuh.
     */
    function getMinimumDug() external view returns (uint256);

    /** @notice reads the sequencerAddress storage variable.
     *  @return address value for the sequencerAddress.
     */
    function getSequencerAddress() external view returns (address);

    /** @notice reads the automationFee storage variable.
     *  @return uint256 value for the automation fee.
     */
    function getAutomationFee() external view returns (uint256);

    /** @notice reads the oracleAddress storage variable.
     *  @return address for the oracle smart contract.
     */
    function getOracleAddress() external view returns (address);

    /** @notice reads the acceptingNewAccounts storage variabel.
     *  @return bool value that indicates if contract is accepting the
     *  creation of new accounts (true) or not (false).
     */
    function getAcceptingNewAccounts() external view returns (bool);
}
