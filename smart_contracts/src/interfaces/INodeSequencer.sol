// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM) and @EWCunha
 *  @title Node sequencer interface
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

interface INodeSequencer {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev Error for when caller is not EOA (Externally Owned Wallet).
    error NodeSequencer__CallerNotEOA();

    /// @dev Error for when node has invalid status.
    error NodeSequencer__InvalidStatus();

    /// @dev Error fot when a node does not have enough DUH funds.
    error NodeSequencer__NotEnoguhDuhFunds();

    /// @dev Error for when node is not allowed to take block numbers.
    error NodeSequencer__NodeCannotTakeBlockNumbers();

    /// @dev Error for when given time period is invalid.
    error NodeSequencer__InvalidTimePeriodForNode();

    /// @dev Error for when start block number is invalid.
    error NodeSequencer__InvalidStartBlockNumber();

    /// @dev Error for when given automation node is equal to address(0).
    error NodeSequencer__InvalidAddress();

    /// @dev Error for when given block number range is invalid.
    error NodeSequencer__InvalidBlockNumberRange();

    /// @dev Error for when NodeSequencer contract is not accepting new nodes.
    error NodeSequencer__NotAcceptingNewNodes();

    /// -----------------------------------------------------------------------
    /// Type declarations (structs and enums)
    /// -----------------------------------------------------------------------

    /** @dev Contains all necessary information of a node.
     *  @param startBlockNumber: start block number for automation.
     *  @param endBlockNumber: end block number for automation.
     *  @param isActive: true if the node is active, false otherwise.
     */
    struct Node {
        uint256 startBlockNumber;
        uint256 endBlockNumber;
        bool isActive;
    }

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /** @dev Event for when a new node is registered.
     *  @param node: node address.
     *  @param startBlockNumber: start block number for automation.
     *  @param endBlockNumber: end block number for automation.
     */
    event NodeRegistered(
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 indexed endBlockNumber
    );

    /** @dev Event for when a node is removed from registry.
     *  @param node: node address.
     *  @param startBlockNumber: start block number for automation.
     *  @param endBlockNumber: end block number for automation.
     */
    event NodeRemoved(
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 indexed endBlockNumber
    );

    /** @dev Event for when block numbers were taken.
     *  @param node: node address.
     *  @param startBlockNumber: start block number for automation.
     *  @param endBlockNumber: end block number for automation.
     */
    event BlockNumbersTaken(
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 indexed endBlockNumber
    );

    /** @dev Event for when the next block numbers range were taken.
     *  @param caller: address of the function caller.
     *  @param node: node address.
     *  @param startBlockNumber: start block number for automation.
     *  @param endBlockNumber: end block number for automation.
     */
    event NextBlockNumbersTakens(
        address indexed caller,
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 endBlockNumber
    );

    /** @dev Event for when a new time period for calculating the block number range for nodes is set.
     *  @param caller: address of the function caller.
     *  @param timePeriodForNode: period of time to be used in the block number range calculation.
     */
    event TimePeriodForNodeSet(
        address indexed caller,
        uint256 timePeriodForNode
    );

    /** @dev Event for when a new automation layer is set
     *  @param caller: address of the function caller.
     *  @param automationLayer: address of the new automation layer.
     */
    event AutomationLayerSet(
        address indexed caller,
        address indexed automationLayer
    );

    /** @dev Event for when a new value for accepting new nodes is set.
     *  @param caller: address of the function caller.
     *  @param acceptingNewNodes: new value for accepting new nodes.
     */
    event AccpectingNewNodesSet(address indexed caller, bool acceptingNewNodes);

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    /// @notice Registers new automation node.
    function registerNode() external;

    /// @notice Removes registered automation node.
    function removeNode() external;

    /** @notice Assigns range of block numbers to a node.
     *  @param startBlockNumber: starting block number of the range.
     */
    function takeBlockNumbers(uint256 startBlockNumber) external;

    /// @notice Assigns the next available range of block numbers to a node.
    function takeNextBlockNumbers() external;

    /** @notice Assigns the next available range of block numbers to the given node.
     *  @param node: auotmation node address.
     */
    function takeNextBlockNumbers(address node) external;

    /** @notice Sets new time period used for calculating the block numbers range.
     *  @param timePeriodForNode: period of time to be used in the block number range calculation.
     */
    function setTimePeriodForNode(uint256 timePeriodForNode) external;

    /** @notice Sets new address for the automation layer
     *  @param automationLayer: new automation layer address.
     */
    function setAutomationLayer(address automationLayer) external;

    /** @notice Sets new value for accepting new nodes.
     *  @param acceptingNewNodes: new value for accepting new nodes.
     */
    function setAcceptingNewNodes(bool acceptingNewNodes) external;

    /** @notice Reads the timePeriodForNode storage variable.
     *  @return uint256 current value for the timePeriodForNode variable.
     */
    function getTimePeriodForNode() external view returns (uint256);

    /** @notice Reads the startBlockNumber storage variable
     *  @return uint256 current value for the startBlockNumber variable.
     */
    function getStartBlockNumber() external view returns (uint256);

    /** @notice Reads the automationLayer storage variable
     *  @return address for the current automation layer smart contract.
     */
    function getAutomationLayer() external view returns (address);

    /** @notice Reads the accpetingNewNodes storage variable.
     *  @return bool for the current value of the accpetingNewNodes variable.
     */
    function getAcceptingNewNodes() external view returns (bool);

    /** @notice Gets the current assigned node for the given block number.
     *  @param blockNumber: block number.
     *  @return address of the assigned node.
     */
    function getBlockNumberToNode(
        uint256 blockNumber
    ) external view returns (address);

    /** @notice Gets an array of node addresses current assigned to the given range of block numbers.
     *  @param startBlockNumber: starting block number of the range.
     *  @param endBlockNumber: ending block number of the range.
     *  @return address array of the current assigned nodes.
     */
    function getRangeOfBlockNumbersToNode(
        uint256 startBlockNumber,
        uint256 endBlockNumber
    ) external view returns (address[] memory);

    /** @notice Gets the node info for the given node address.
     *  @param node: node address.
     *  @return Node struct with the node information.
     */
    function getNode(address node) external view returns (Node memory);

    /** @notice Gets the node that is currently automating.
     *  @return address and Node struct of the current automating node.
     */
    function getCurrentNode() external view returns (address, Node memory);

    /** @notice Checks if given node address is the current node.
     *  @param node: node address.
     *  @return bool value that specified is given node is the current node (true) or not (false).
     */
    function isCurrentNode(address node) external view returns (bool);
}
