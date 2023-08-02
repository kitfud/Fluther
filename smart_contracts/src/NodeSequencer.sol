// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/** @author Levi Webb (@DopaMIM) and @EWcunha
 *  @title Automation layer smart contract
 *  This code is proprietary and confidential. All rights reserved.
 *  Unauthorized copying of this file, via any medium is strictly prohibited.
 *  Proprietary code by Levi Webb
 */

// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {console} from "forge-std/Test.sol";
import {INodeSequencer} from "./interfaces/INodeSequencer.sol";
import {IAutomationLayer} from "./interfaces/IAutomationLayer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Security} from "./Security.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract NodeSequencer is INodeSequencer, Security {
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /* solhint-disable */
    // base types
    uint256 private s_timePeriodForNode;
    uint256 private s_startBlockNumber;
    IAutomationLayer private s_automationLayer;
    bool private s_acceptingNewNodes;

    // mappings and arrays
    mapping(uint256 /* blockNumber */ => address /* node */)
        private s_blockNumberToNode;
    mapping(address /* node */ => Node /* info */) private s_nodes;

    // constants
    uint256 private constant AVERAGE_TIME_PER_BLOCK = 15 seconds;
    uint256 private constant MAX_TIME_FOR_NODE = 7 days;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Modifiers (or private functions as modifiers)
    /// -----------------------------------------------------------------------

    /// @dev Only EOA can call the function.
    function __onlyEOA() private view {
        if (msg.sender != tx.origin) {
            revert NodeSequencer__CallerNotEOA();
        }
    }

    /** @dev Checks if node has the given status.
     *  @param node: the address of the node.
     *  @param value: the status value to checked.
     */
    function __checkNodeStatus(address node, bool value) private view {
        if (s_nodes[node].isActive != value) {
            revert NodeSequencer__InvalidStatus();
        }
    }

    /** @dev Checks if given node address has sufficient DUH tokens.
     *  @param node: the address of the node.
     */
    function __checkDuhFunds(address node) private view {
        if (!__hasDuhFunds(node)) {
            revert NodeSequencer__NotEnoguhDuhFunds();
        }
    }

    /** @dev Checks if given node address has not yet operated block numbers.
     *  @param node: the address of the node.
     */
    function __checkNodeBlockNumberRange(address node) private view {
        if (!(s_nodes[node].endBlockNumber < block.number)) {
            revert NodeSequencer__NodeCannotTakeBlockNumbers();
        }
    }

    /** @dev Validates the given time period for node parameter.
     *  @param timePeriodForNode: time period to be used in the calculation of block number range.
     */
    function __validateTimePeriodForNode(
        uint256 timePeriodForNode
    ) private pure {
        if (timePeriodForNode > MAX_TIME_FOR_NODE) {
            revert NodeSequencer__InvalidTimePeriodForNode();
        }
    }

    /// @dev checks if it is currently accepting new nodes.
    function __isAcceptingNewNodes() private view {
        if (!s_acceptingNewNodes) {
            revert NodeSequencer__NotAcceptingNewNodes();
        }
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /** @notice Constructor logic.
     *  @param timePeriodForNode: time period to be used in the calculation of block number range
     *  @param automationLayer: address of the automation layer smart contract.
     */
    constructor(
        uint256 timePeriodForNode,
        address automationLayer
    ) Security(msg.sender) {
        __validateTimePeriodForNode(timePeriodForNode);

<<<<<<< HEAD
        minimumDuh = 0;
        blockNumberRange = 1000;
        duh = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC on Polygon
        //duh = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH on Ethereum
=======
        s_timePeriodForNode = timePeriodForNode;
        s_startBlockNumber = block.number;
        s_automationLayer = IAutomationLayer(automationLayer);
        s_acceptingNewNodes = true;
>>>>>>> 8e582c487af948970f76f7e24a1ca4aeefdebf0b
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    /** @dev Added the nonReentrant and whenNotPaused third party modifiers. It will
     *  also revert either if contrat is not accepting new nodes, or if caller is
     *  already a registered node, or if caller is not an EOA.
     *  @inheritdoc INodeSequencer
     */
    function registerNode() external override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __isAcceptingNewNodes();
        __checkNodeStatus(msg.sender, false);
        __onlyEOA();

        uint256 startBlockNumber;
        uint256 endBlockNumber;
        if (__hasDuhFunds(msg.sender)) {
            startBlockNumber = s_startBlockNumber;
            startBlockNumber = startBlockNumber == block.number
                ? startBlockNumber + 1
                : startBlockNumber;
            endBlockNumber =
                startBlockNumber +
                s_timePeriodForNode /
                AVERAGE_TIME_PER_BLOCK;

            s_startBlockNumber = endBlockNumber + 1;
        }

        s_nodes[msg.sender] = Node({
            startBlockNumber: startBlockNumber,
            endBlockNumber: endBlockNumber,
            isActive: true
        });

        if (startBlockNumber != 0) {
            __assignBlockNumbers(startBlockNumber, endBlockNumber, msg.sender);
        }

        emit NodeRegistered(msg.sender, startBlockNumber, endBlockNumber);
    }

    /** @dev Added the nonReentrant and whenNotPaused third party modifiers. It will
     *  also revert if caller is not a registered node.
     *  @inheritdoc INodeSequencer
     */
    function removeNode() external override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __checkNodeStatus(msg.sender, true);

        Node memory node = s_nodes[msg.sender];
        s_nodes[msg.sender].isActive = false;

        __assignBlockNumbers(
            node.startBlockNumber,
            node.endBlockNumber,
            address(0)
        );

        emit NodeRemoved(
            msg.sender,
            node.startBlockNumber,
            node.endBlockNumber
        );
    }

    /** @dev Added the nonReentrant and whenNotPaused third party modifiers. It will
     *  also revert if one or more of the following happens:
     *  1. contract is not accepting new nodes;
     *  2. caller is already a registered node;
     *  3. caller does not have enough DUH tokens;
     *  4. caller has a block number range assigned that were not yer processed;
     *  5. caller is not an EOA.
     *  @inheritdoc INodeSequencer
     */
    function takeBlockNumbers(
        uint256 startBlockNumber
    ) external override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __isAcceptingNewNodes();
        __checkNodeStatus(msg.sender, false);
        __checkDuhFunds(msg.sender);
        __checkNodeBlockNumberRange(msg.sender);
        __onlyEOA();

        uint256 currStartBlockNumber = s_startBlockNumber;
        if (
            startBlockNumber > currStartBlockNumber ||
            startBlockNumber < block.number
        ) {
            revert NodeSequencer__InvalidStartBlockNumber();
        }

        startBlockNumber = startBlockNumber == block.number
            ? startBlockNumber + 1
            : startBlockNumber;
        uint256 endBlockNumber = startBlockNumber +
            s_timePeriodForNode /
            AVERAGE_TIME_PER_BLOCK;

        if (
            startBlockNumber == currStartBlockNumber ||
            endBlockNumber > currStartBlockNumber
        ) {
            s_startBlockNumber = endBlockNumber + 1;
        }

        (
            uint256 actualStartBlockNumber,
            uint256 actualEndBlockNumber
        ) = __assignOnlyNotTakenBlockNumbers(
                startBlockNumber,
                endBlockNumber,
                msg.sender
            );

        s_nodes[msg.sender] = Node({
            startBlockNumber: actualStartBlockNumber,
            endBlockNumber: actualEndBlockNumber,
            isActive: true
        });

        emit BlockNumbersTaken(msg.sender, startBlockNumber, endBlockNumber);
    }

    /// @dev Calls the takeNextBlockNumbers(address node) public function.
    function takeNextBlockNumbers() external override(INodeSequencer) {
        takeNextBlockNumbers(msg.sender);
    }

    /** @dev Added the nonReentrant and whenNotPaused third party modifiers. It will
     *  also revert if one or more of the following happens:
     *  1. caller is not a registered node;
     *  2. caller does not have enough DUH tokens;
     *  3. caller has a block number range assigned that were not yer processed.
     *  @inheritdoc INodeSequencer
     */
    function takeNextBlockNumbers(
        address node
    ) public override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __checkNodeStatus(node, true);
        __checkDuhFunds(node);
        __checkNodeBlockNumberRange(node);

        uint256 startBlockNumber = s_startBlockNumber;
        startBlockNumber = startBlockNumber < block.number
            ? block.number
            : startBlockNumber;
        uint256 endBlockNumber = startBlockNumber +
            s_timePeriodForNode /
            AVERAGE_TIME_PER_BLOCK;

        s_startBlockNumber = endBlockNumber + 1;

        s_nodes[node].startBlockNumber = startBlockNumber;
        s_nodes[node].endBlockNumber = endBlockNumber;

        __assignBlockNumbers(startBlockNumber, endBlockNumber, node);

        emit NextBlockNumbersTakens(
            msg.sender,
            node,
            startBlockNumber,
            endBlockNumber
        );
    }

    /** @dev Added the nonReentrant, whenNotPaused, and onlyOwner third party modifiers. It will
     *  also revert if given value is not valid.
     *  @inheritdoc INodeSequencer
     */
    function setTimePeriodForNode(
        uint256 timePeriodForNode
    ) external override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();
        __validateTimePeriodForNode(timePeriodForNode);

        s_timePeriodForNode = timePeriodForNode;

        emit TimePeriodForNodeSet(msg.sender, timePeriodForNode);
    }

    /** @dev Added the nonReentrant, whenNotPaused, and onlyOwner third party modifiers. It will
     *  also revert if given value is not valid.
     *  @inheritdoc INodeSequencer
     */
    function setAutomationLayer(
        address automationLayer
    ) external override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        if (automationLayer == address(0)) {
            revert NodeSequencer__InvalidAddress();
        }

        s_automationLayer = IAutomationLayer(automationLayer);

        emit AutomationLayerSet(msg.sender, automationLayer);
    }

    /** @dev Added the nonReentrant, whenNotPaused, and onlyOwner third party modifiers.
     *  @inheritdoc INodeSequencer
     */
    function setAcceptingNewNodes(
        bool acceptingNewNodes
    ) external override(INodeSequencer) {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_acceptingNewNodes = acceptingNewNodes;

        emit AccpectingNewNodesSet(msg.sender, acceptingNewNodes);
    }

    /// -----------------------------------------------------------------------
    /// Internal state-change functions
    /// -----------------------------------------------------------------------

    /** @dev Assigns range of block numbers to a node address.
     *  @param startBlockNumber: staring block number of the range.
     *  @param endBlockNumber: ending block number of the range.
     *  @param node: node address.
     */
    function __assignBlockNumbers(
        uint256 startBlockNumber,
        uint256 endBlockNumber,
        address node
    ) private {
        for (uint256 ii = startBlockNumber; ii < endBlockNumber + 1; ++ii) {
            s_blockNumberToNode[ii] = node;
        }
    }

    /** @dev Assigns range of block numbers to a node address. It will only assign not yet
     *  assigned block numbers.
     *  @param startBlockNumber: staring block number of the range.
     *  @param endBlockNumber: ending block number of the range.
     *  @param node: node address.
     *  @return uint256 value for the actual assigned starting block number and uint256 for
     *  the actual assigned ending block number.
     */
    function __assignOnlyNotTakenBlockNumbers(
        uint256 startBlockNumber,
        uint256 endBlockNumber,
        address node
    ) private returns (uint256, uint256) {
        uint256 takenStartBlockNumber;
        for (uint256 ii = startBlockNumber; ii < endBlockNumber + 1; ++ii) {
            if (s_blockNumberToNode[ii] == address(0)) {
                s_blockNumberToNode[ii] = node;
                if (takenStartBlockNumber == 0) {
                    takenStartBlockNumber = ii;
                }
            }
        }

        return (
            takenStartBlockNumber,
            takenStartBlockNumber != 0 ? endBlockNumber : 0
        );
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc INodeSequencer
    function getTimePeriodForNode()
        external
        view
        override(INodeSequencer)
        returns (uint256)
    {
        return s_timePeriodForNode;
    }

    /// @inheritdoc INodeSequencer
    function getStartBlockNumber()
        external
        view
        override(INodeSequencer)
        returns (uint256)
    {
        return s_startBlockNumber;
    }

    /// @inheritdoc INodeSequencer
    function getAutomationLayer()
        external
        view
        override(INodeSequencer)
        returns (address)
    {
        return address(s_automationLayer);
    }

    /// @inheritdoc INodeSequencer
    function getAcceptingNewNodes()
        external
        view
        override(INodeSequencer)
        returns (bool)
    {
        return s_acceptingNewNodes;
    }

    /// @inheritdoc INodeSequencer
    function getBlockNumberToNode(
        uint256 blockNumber
    ) external view override(INodeSequencer) returns (address) {
        return s_blockNumberToNode[blockNumber];
    }

    /// @inheritdoc INodeSequencer
    function getRangeOfBlockNumbersToNode(
        uint256 startBlockNumber,
        uint256 endBlockNumber
    ) external view override(INodeSequencer) returns (address[] memory) {
        if (
            startBlockNumber > endBlockNumber ||
            endBlockNumber > s_startBlockNumber
        ) {
            revert NodeSequencer__InvalidBlockNumberRange();
        }
        address[] memory nodes = new address[](
            endBlockNumber - startBlockNumber + 1
        );

        for (uint256 ii = startBlockNumber; ii < endBlockNumber + 1; ++ii) {
            nodes[ii - startBlockNumber] = s_blockNumberToNode[ii];
        }

        return nodes;
    }

    /// @inheritdoc INodeSequencer
    function getNode(
        address node
    ) external view override(INodeSequencer) returns (Node memory) {
        return s_nodes[node];
    }

    /// @inheritdoc INodeSequencer
    function getCurrentNode()
        external
        view
        override(INodeSequencer)
        returns (address, Node memory)
    {
        return (
            s_blockNumberToNode[block.number],
            s_nodes[s_blockNumberToNode[block.number]]
        );
    }

    /// @inheritdoc INodeSequencer
    function isCurrentNode(
        address node
    ) external view override(INodeSequencer) returns (bool) {
        return node == s_blockNumberToNode[block.number];
    }

    /// -----------------------------------------------------------------------
    /// Internal view functions
    /// -----------------------------------------------------------------------

    /** @dev Checks if given node address has enough DUH tokens.
     *  @param node: node address to check.
     *  @return true if node address has enough DUH tokens, false otherwise.
     */
    function __hasDuhFunds(address node) private view returns (bool) {
        uint256 minimumDuh = s_automationLayer.getMinimumDuh();
        IERC20 duhToken = IERC20(s_automationLayer.getDuh());

        return !(duhToken.balanceOf(node) < minimumDuh);
    }
}
