// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
/** @author @EWCunha
 *  @title NodeSequencer smart contract unit test
 */

<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "../../script/Deploy.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AutomationLayer, IAutomationLayer} from "../../src/AutomationLayer.sol";
import {DollarCostAverage} from "../../src/DollarCostAverage.sol";
import {NodeSequencer, INodeSequencer} from "../../src/NodeSequencer.sol";
import {Duh} from "../../src/Duh.sol";
import {Security} from "../../src/Security.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract NodeSequencerTest is Test {
    /* solhint-disable */
    Deploy deployer;
    HelperConfig config;
    AutomationLayer automation;
    NodeSequencer sequencer;
    Duh duhToken;
    address signer;
    uint256 timePeriodForNode;

    address public user = makeAddr("user");
    address public anotherUser = makeAddr("anotherUser");
    address public PAYMENT_INTERFACE = makeAddr("userInterface");

    uint256 public constant INITIAL_DUH_MINT = 1 ether;
    uint256 public constant INITIAL_USER_ERC20_FUNDS = 100 ether;
    uint256 public constant INITIAL_USER_FUNDS = 100 ether;
    uint256 public constant AVERAGE_TIME_PER_BLOCK = 15 seconds;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Events to test
    /// -----------------------------------------------------------------------

    event NodeRegistered(
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 indexed endBlockNumber
    );

    event NodeRemoved(
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 indexed endBlockNumber
    );

    event BlockNumbersTaken(
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 indexed endBlockNumber
    );

    event NextBlockNumbersTakens(
        address indexed caller,
        address indexed node,
        uint256 indexed startBlockNumber,
        uint256 endBlockNumber
    );

    event TimePeriodForNodeSet(
        address indexed caller,
        uint256 timePeriodForNode
    );

    event AutomationLayerSet(
        address indexed caller,
        address indexed automationLayer
    );

    event AccpectingNewNodesSet(address indexed caller, bool acceptingNewNodes);

    /// -----------------------------------------------------------------------
    /// Tests set-up
    /// -----------------------------------------------------------------------

    function setUp() public {
        deployer = new Deploy();
        deployer.run();

        automation = deployer.automation();
        config = deployer.config();
        sequencer = deployer.sequencer();
        duhToken = deployer.duh();
        timePeriodForNode = deployer.timePeriodForNode();

        (address wNative, , address duh, , , , , , uint256 deployerPk) = config
            .activeNetworkConfig();

        signer = vm.addr(deployerPk);
        vm.deal(user, INITIAL_USER_FUNDS);
        duhToken = address(duhToken) == address(0) ? Duh(duh) : duhToken;

        if (block.chainid == 11155111) {
            vm.prank(user);
            wNative.call{value: 1 ether}("");
        } else {
            ERC20Mock(wNative).mint(user, INITIAL_USER_ERC20_FUNDS);
        }
    }

    modifier pause() {
        vm.prank(signer);
        sequencer.pause();
        _;
    }

    /// -----------------------------------------------------------------------
    /// Test for: constructor
    /// -----------------------------------------------------------------------

    function testConstructorSuccess() public {
        uint256 timePeriod = sequencer.getTimePeriodForNode();
        address automationLayer = sequencer.getAutomationLayer();
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        bool acceptingNewNodes = sequencer.getAcceptingNewNodes();

        assertEq(timePeriod, timePeriodForNode);
        assertEq(automationLayer, address(automation));
        assertEq(startBlockNumber, block.number);
        assertTrue(acceptingNewNodes);
    }

    function testConstructorRevertsIfTimePeriodForNodeIsGreaterThanAllowed()
        public
    {
        uint256 timePeriod = 7 days + 1;

        vm.prank(user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__InvalidTimePeriodForNode.selector
        );
        new NodeSequencer(timePeriod, address(automation));
    }

    /// -----------------------------------------------------------------------
    /// Test for: registerNode
    /// -----------------------------------------------------------------------

    modifier mintAndApproveDuh(address to, uint256 amount) {
        vm.prank(signer);
        duhToken.mint(to, amount);
        _;
    }

    function testRegisterNodeSuccessPath1() public {
        bool isNodeBefore = sequencer.getNode(user).isActive;

        vm.prank(user, user);
        sequencer.registerNode();

        bool isNodeAfter = sequencer.getNode(user).isActive;

        assertTrue(!isNodeBefore);
        assertTrue(isNodeAfter);
    }

    function testRegisterNodeEventPath1() public {
        vm.prank(user, user);
        vm.expectEmit(true, true, true, false, address(sequencer));
        emit NodeRegistered(user, 0, 0);
        sequencer.registerNode();
    }

    function testRegisterNodeSuccessPath2()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        mintAndApproveDuh(anotherUser, INITIAL_DUH_MINT)
    {
        INodeSequencer.Node memory nodeBefore = sequencer.getNode(user);
        uint256 startBlockNumberUser = sequencer.getStartBlockNumber();

        vm.prank(user, user);
        sequencer.registerNode();

        INodeSequencer.Node memory nodeAfter = sequencer.getNode(user);
        INodeSequencer.Node memory nodeBeforeAnotherUser = sequencer.getNode(
            anotherUser
        );
        uint256 startBlockNumberAnotherUser = sequencer.getStartBlockNumber();

        vm.prank(anotherUser, anotherUser);
        sequencer.registerNode();

        INodeSequencer.Node memory nodeAfterAnotherUser = sequencer.getNode(
            anotherUser
        );

        assertTrue(!nodeBefore.isActive);
        assertEq(nodeBefore.startBlockNumber, 0);
        assertEq(nodeBefore.endBlockNumber, 0);
        assertTrue(nodeAfter.isActive);
        assertEq(nodeAfter.startBlockNumber, startBlockNumberUser + 1);
        assertEq(
            nodeAfter.endBlockNumber,
            startBlockNumberUser +
                1 +
                timePeriodForNode /
                AVERAGE_TIME_PER_BLOCK
        );

        assertTrue(!nodeBeforeAnotherUser.isActive);
        assertEq(nodeBeforeAnotherUser.startBlockNumber, 0);
        assertEq(nodeBeforeAnotherUser.endBlockNumber, 0);
        assertTrue(nodeAfterAnotherUser.isActive);
        assertEq(
            nodeAfterAnotherUser.startBlockNumber,
            startBlockNumberAnotherUser
        );
        assertEq(
            nodeAfterAnotherUser.endBlockNumber,
            startBlockNumberAnotherUser +
                timePeriodForNode /
                AVERAGE_TIME_PER_BLOCK
        );
    }

    function testRegisterNodeEventPath2()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        mintAndApproveDuh(anotherUser, INITIAL_DUH_MINT)
    {
        uint256 startBlockNumberUser = sequencer.getStartBlockNumber();

        vm.prank(user, user);
        vm.expectEmit(true, true, true, false, address(sequencer));
        emit NodeRegistered(
            user,
            startBlockNumberUser + 1,
            startBlockNumberUser +
                1 +
                timePeriodForNode /
                AVERAGE_TIME_PER_BLOCK
        );
        sequencer.registerNode();

        uint256 startBlockNumberAnotherUser = sequencer.getStartBlockNumber();

        vm.prank(anotherUser, anotherUser);
        vm.expectEmit(true, true, true, false, address(sequencer));
        emit NodeRegistered(
            anotherUser,
            startBlockNumberAnotherUser,
            startBlockNumberAnotherUser +
                timePeriodForNode /
                AVERAGE_TIME_PER_BLOCK
        );
        sequencer.registerNode();
    }

    function testRegisterNodeRevertsIfNotAcceptingNewNodes() public {
        vm.prank(signer);
        sequencer.setAcceptingNewNodes(false);

        vm.prank(user, user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__NotAcceptingNewNodes.selector
        );
        sequencer.registerNode();
    }

    function testRegisterNodeRevertsIfNodeAlreadyRegistered() public {
        vm.startPrank(user, user);
        sequencer.registerNode();

        vm.expectRevert(INodeSequencer.NodeSequencer__InvalidStatus.selector);
        sequencer.registerNode();
        vm.stopPrank();
    }

    function testRegisterNodeRevertsIfCallerNotEOA() public {
        vm.prank(user);
        vm.expectRevert(INodeSequencer.NodeSequencer__CallerNotEOA.selector);
        sequencer.registerNode();
    }

    function testRegisterNodeRevertsIfContractPaused() public pause {
        vm.prank(user, user);
        vm.expectRevert("Pausable: paused");
        sequencer.registerNode();
    }

    /// -----------------------------------------------------------------------
    /// Test for: removeNode
    /// -----------------------------------------------------------------------

    modifier registerNode(address user_) {
        vm.prank(user_, user_);
        sequencer.registerNode();
        _;
    }

    function testRemoveNodeSuccess()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        INodeSequencer.Node memory nodeBefore = sequencer.getNode(user);

        vm.prank(user);
        sequencer.removeNode();

        INodeSequencer.Node memory nodeAfter = sequencer.getNode(user);

        assertTrue(nodeBefore.isActive);
        assertTrue(nodeBefore.startBlockNumber > 0);
        assertTrue(nodeBefore.endBlockNumber > 0);

        assertTrue(!nodeAfter.isActive);
        assertTrue(nodeAfter.startBlockNumber > 0);
        assertTrue(nodeAfter.endBlockNumber > 0);
    }

    function testRemoveNodeRevertsIfNodeNotActive() public {
        vm.prank(user);
        vm.expectRevert(INodeSequencer.NodeSequencer__InvalidStatus.selector);
        sequencer.removeNode();
    }

    function testRemoveNodeRevertsIfContractPaused() public pause {
        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        sequencer.removeNode();
    }

    /// -----------------------------------------------------------------------
    /// Test for: takeBlockNumbers
    /// -----------------------------------------------------------------------

    function testTakeBlockNumbersSuccessPath1()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
    {
        uint256 startBlockNumber = block.number;
        INodeSequencer.Node memory nodeBefore = sequencer.getNode(user);

        vm.prank(user, user);
        vm.expectEmit(true, true, true, false, address(sequencer));
        emit BlockNumbersTaken(
            user,
            startBlockNumber + 1,
            startBlockNumber + 1 + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
        sequencer.takeBlockNumbers(startBlockNumber);

        INodeSequencer.Node memory nodeAfter = sequencer.getNode(user);

        assertTrue(!nodeBefore.isActive);
        assertEq(nodeBefore.startBlockNumber, 0);
        assertEq(nodeBefore.endBlockNumber, 0);

        assertTrue(nodeAfter.isActive);
        assertEq(nodeAfter.startBlockNumber, startBlockNumber + 1);
        assertEq(
            nodeAfter.endBlockNumber,
            startBlockNumber + 1 + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
    }

    function testTakeBlockNumbersSuccessPath2()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        mintAndApproveDuh(anotherUser, INITIAL_DUH_MINT)
        mintAndApproveDuh(makeAddr("thirdUser"), INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        INodeSequencer.Node memory nodeBefore = sequencer.getNode(anotherUser);

        vm.prank(anotherUser, anotherUser);
        vm.expectEmit(true, true, true, false, address(sequencer));
        emit BlockNumbersTaken(
            anotherUser,
            startBlockNumber,
            startBlockNumber + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
        sequencer.takeBlockNumbers(startBlockNumber);

        INodeSequencer.Node memory nodeAfter = sequencer.getNode(anotherUser);

        assertTrue(!nodeBefore.isActive);
        assertEq(nodeBefore.startBlockNumber, 0);
        assertEq(nodeBefore.endBlockNumber, 0);

        assertTrue(nodeAfter.isActive);
        assertEq(nodeAfter.startBlockNumber, startBlockNumber);
        assertEq(
            nodeAfter.endBlockNumber,
            startBlockNumber + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );

        startBlockNumber = sequencer.getStartBlockNumber() - 1;
        address thirdUser = makeAddr("thirdUser");

        vm.prank(thirdUser, thirdUser);
        vm.expectEmit(true, true, true, false, address(sequencer));
        emit BlockNumbersTaken(
            thirdUser,
            startBlockNumber,
            startBlockNumber + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
        sequencer.takeBlockNumbers(startBlockNumber);
    }

    function testTakeBlockNumbersRevertsIfNotAcceptingNewNodes()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();

        vm.prank(signer);
        sequencer.setAcceptingNewNodes(false);

        vm.prank(user, user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__NotAcceptingNewNodes.selector
        );
        sequencer.takeBlockNumbers(startBlockNumber);
    }

    function testTakeBlockNumbersRevertsIfNodeAlreadyRegistered()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();

        vm.prank(user, user);
        vm.expectRevert(INodeSequencer.NodeSequencer__InvalidStatus.selector);
        sequencer.takeBlockNumbers(startBlockNumber);
    }

    function testTakeBlockNumbersRevertsIfNotEnoughDuhFunds() public {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();

        vm.prank(user, user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__NotEnoguhDuhFunds.selector
        );
        sequencer.takeBlockNumbers(startBlockNumber);
    }

    function testTakeBlockNumbersRevertsIfNodeEndBlockNumberNotPast()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();

        vm.startPrank(user, user);
        sequencer.removeNode();
        vm.expectRevert(
            INodeSequencer.NodeSequencer__NodeCannotTakeBlockNumbers.selector
        );
        sequencer.takeBlockNumbers(startBlockNumber);
        vm.stopPrank();
    }

    function testTakeBlockNumbersRevertsIfCallerNotEOA()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();

        vm.prank(user);
        vm.expectRevert(INodeSequencer.NodeSequencer__CallerNotEOA.selector);
        sequencer.takeBlockNumbers(startBlockNumber);
    }

    function testTakeBlockNumbersRevertsIfInvalidBlockNumberIsGiven()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber() + 1;

        vm.prank(user, user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__InvalidStartBlockNumber.selector
        );
        sequencer.takeBlockNumbers(startBlockNumber);

        startBlockNumber = block.number - 1;

        vm.prank(user, user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__InvalidStartBlockNumber.selector
        );
        sequencer.takeBlockNumbers(startBlockNumber);
    }

    /// -----------------------------------------------------------------------
    /// Test for: takeNextBlockNumbers(address)
    /// -----------------------------------------------------------------------

    function testTakeNextBlockNumbersSuccess()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        uint256 endBlockNumber = startBlockNumber +
            timePeriodForNode /
            AVERAGE_TIME_PER_BLOCK;

        vm.roll(endBlockNumber + 1);

        INodeSequencer.Node memory nodeBefore = sequencer.getNode(user);

        vm.prank(user);
        sequencer.takeNextBlockNumbers(user);

        INodeSequencer.Node memory nodeAfter = sequencer.getNode(user);

        assertTrue(nodeBefore.isActive);
        assertTrue(nodeBefore.startBlockNumber < startBlockNumber);
        assertEq(nodeBefore.endBlockNumber, startBlockNumber - 1);

        assertTrue(nodeAfter.isActive);
        assertEq(nodeAfter.startBlockNumber, endBlockNumber + 1);
        assertEq(
            nodeAfter.endBlockNumber,
            endBlockNumber + 1 + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
    }

    function testTakeNextBlockNumbersEvent()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        uint256 endBlockNumber = startBlockNumber +
            timePeriodForNode /
            AVERAGE_TIME_PER_BLOCK;

        vm.roll(endBlockNumber + 1);

        vm.prank(user);
        vm.expectEmit(true, true, true, true, address(sequencer));
        emit NextBlockNumbersTakens(
            user,
            user,
            endBlockNumber + 1,
            endBlockNumber + 1 + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
        sequencer.takeNextBlockNumbers(user);
    }

    function testTakeNextBlockNumbersRevertsIfNodeNotRegistered()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
    {
        vm.prank(user);
        vm.expectRevert(INodeSequencer.NodeSequencer__InvalidStatus.selector);
        sequencer.takeNextBlockNumbers(user);
    }

    function testTakeNextBlockNumbersRevertsIfNotEnoughDuhFunds()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        uint256 endBlockNumber = startBlockNumber +
            timePeriodForNode /
            AVERAGE_TIME_PER_BLOCK;

        vm.roll(endBlockNumber + 1);
        uint256 currentBalance = duhToken.balanceOf(user);

        vm.startPrank(user);
        duhToken.transfer(anotherUser, currentBalance);
        vm.roll(endBlockNumber + 1);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__NotEnoguhDuhFunds.selector
        );
        sequencer.takeNextBlockNumbers(user);
        vm.stopPrank();
    }

    function testTakeNextBlockNumbersRevertsIfNotAllowedBlockNumberRange()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        vm.prank(user);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__NodeCannotTakeBlockNumbers.selector
        );
        sequencer.takeNextBlockNumbers(user);
    }

    function testTakeNextBlockNumbersRevertsIfContractPaused()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
        pause
    {
        vm.prank(user);
        vm.expectRevert("Pausable: paused");
        sequencer.takeNextBlockNumbers(user);
    }

    /// -----------------------------------------------------------------------
    /// Test for: takeNextBlockNumbers()
    /// -----------------------------------------------------------------------

    function testTakeNextBlockNumbersNoAddressSuccess()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        uint256 endBlockNumber = startBlockNumber +
            timePeriodForNode /
            AVERAGE_TIME_PER_BLOCK;

        vm.roll(endBlockNumber + 1);

        INodeSequencer.Node memory nodeBefore = sequencer.getNode(user);

        vm.prank(user);
        sequencer.takeNextBlockNumbers();

        INodeSequencer.Node memory nodeAfter = sequencer.getNode(user);

        assertTrue(nodeBefore.isActive);
        assertTrue(nodeBefore.startBlockNumber < startBlockNumber);
        assertEq(nodeBefore.endBlockNumber, startBlockNumber - 1);

        assertTrue(nodeAfter.isActive);
        assertEq(nodeAfter.startBlockNumber, endBlockNumber + 1);
        assertEq(
            nodeAfter.endBlockNumber,
            endBlockNumber + 1 + timePeriodForNode / AVERAGE_TIME_PER_BLOCK
        );
    }

    /// -----------------------------------------------------------------------
    /// Test for: setTimePeriodForNode
    /// -----------------------------------------------------------------------

    function testSetTimePeriodForNodeSuccess() public {
        uint256 newTimePeriod = 2 days;
        uint256 timePeriodBefore = sequencer.getTimePeriodForNode();

        vm.prank(signer);
        sequencer.setTimePeriodForNode(newTimePeriod);

        uint256 timePeriodAfter = sequencer.getTimePeriodForNode();

        assertEq(timePeriodBefore, timePeriodForNode);
        assertEq(timePeriodAfter, newTimePeriod);
    }

    function testSetTimePeriodForNodeEvent() public {
        uint256 newTimePeriod = 2 days;

        vm.prank(signer);
        vm.expectEmit(true, false, false, true, address(sequencer));
        emit TimePeriodForNodeSet(signer, newTimePeriod);
        sequencer.setTimePeriodForNode(newTimePeriod);
    }

    function testSetTimePeriodForNodeRevertsIfCallerNotAllowed() public {
        uint256 newTimePeriod = 2 days;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        sequencer.setTimePeriodForNode(newTimePeriod);
    }

    function testSetTimePeriodForNodeRevertsIfGivenTimePeriodIsGreaterThanAllowed()
        public
    {
        uint256 newTimePeriod = 7 days + 1;

        vm.prank(signer);
        vm.expectRevert(
            INodeSequencer.NodeSequencer__InvalidTimePeriodForNode.selector
        );
        sequencer.setTimePeriodForNode(newTimePeriod);
    }

    function testSetTimePeriodForNodeRevertsIfContractPaused() public pause {
        uint256 newTimePeriod = 7 days + 1;

        vm.prank(signer);
        vm.expectRevert("Pausable: paused");
        sequencer.setTimePeriodForNode(newTimePeriod);
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAutomationLayer
    /// -----------------------------------------------------------------------

    function testSetAutomationLayerSuccess() public {
        address newAutomationLayer = makeAddr("automation");
        address autoLayerBefore = sequencer.getAutomationLayer();

        vm.prank(signer);
        sequencer.setAutomationLayer(newAutomationLayer);

        address autoLayerAfter = sequencer.getAutomationLayer();

        assertEq(autoLayerBefore, address(automation));
        assertEq(autoLayerAfter, newAutomationLayer);
    }

    function testSetAutomationLayerEvent() public {
        address newAutomationLayer = makeAddr("automation");

        vm.prank(signer);
        vm.expectEmit(true, false, false, true, address(sequencer));
        emit AutomationLayerSet(signer, newAutomationLayer);
        sequencer.setAutomationLayer(newAutomationLayer);
    }

    function testSetAutomationLayerRevertsIfCallerNotAllowed() public {
        address newAutomationLayer = makeAddr("automation");

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        sequencer.setAutomationLayer(newAutomationLayer);
    }

    function testSetAutomationLayerRevertsIfGivenAddressIsAddress0() public {
        address newAutomationLayer = address(0);

        vm.prank(signer);
        vm.expectRevert(INodeSequencer.NodeSequencer__InvalidAddress.selector);
        sequencer.setAutomationLayer(newAutomationLayer);
    }

    function testSetAutomationLayerRevertsIfContractPaused() public pause {
        address newAutomationLayer = makeAddr("automation");

        vm.prank(signer);
        vm.expectRevert("Pausable: paused");
        sequencer.setAutomationLayer(newAutomationLayer);
    }

    /// -----------------------------------------------------------------------
    /// Test for: setAcceptingNewNodes
    /// -----------------------------------------------------------------------

    function testSetAcceptingNewNodesSuccess() public {
        bool newAccepNewNodes = false;
        bool acceptBefore = sequencer.getAcceptingNewNodes();

        vm.prank(signer);
        sequencer.setAcceptingNewNodes(newAccepNewNodes);

        bool acceptAfter = sequencer.getAcceptingNewNodes();

        assertTrue(acceptBefore);
        assertEq(acceptAfter, newAccepNewNodes);
    }

    function testSetAcceptingNewNodesEvent() public {
        bool newAccepNewNodes = false;

        vm.prank(signer);
        vm.expectEmit(true, false, false, true, address(sequencer));
        emit AccpectingNewNodesSet(signer, newAccepNewNodes);
        sequencer.setAcceptingNewNodes(newAccepNewNodes);
    }

    function testSetAcceptingNewNodesRevertsIfCallerNotAllowed() public {
        bool newAccepNewNodes = false;

        vm.prank(user);
        vm.expectRevert(Security.Security__NotAllowed.selector);
        sequencer.setAcceptingNewNodes(newAccepNewNodes);
    }

    function testSetAcceptingNewNodesRevertsIfContractPaused() public pause {
        bool newAccepNewNodes = false;

        vm.prank(signer);
        vm.expectRevert("Pausable: paused");
        sequencer.setAcceptingNewNodes(newAccepNewNodes);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getTimePeriodForNode
    /// -----------------------------------------------------------------------

    function testGetTimPeriodForNode() public {
        uint256 timePeriod = sequencer.getTimePeriodForNode();

        assertEq(timePeriod, timePeriodForNode);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getStartBlockNumber
    /// -----------------------------------------------------------------------

    function testGetStartBlockNumber() public {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();

        assertEq(startBlockNumber, block.number);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAutomationLayer
    /// -----------------------------------------------------------------------

    function testGetAutomationLayer() public {
        address autoLayer = sequencer.getAutomationLayer();

        assertEq(autoLayer, address(automation));
    }

    /// -----------------------------------------------------------------------
    /// Test for: getAcceptingNewNodes
    /// -----------------------------------------------------------------------

    function testGetAcceptingNewNodes() public {
        bool accept = sequencer.getAcceptingNewNodes();

        assertTrue(accept);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getBlockNumberToNode
    /// -----------------------------------------------------------------------

    function testGetBlockNumberToNode()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        address node = sequencer.getBlockNumberToNode(startBlockNumber - 1);

        assertEq(node, user);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getRangeOfBlockNumbersToNode
    /// -----------------------------------------------------------------------

    function testGetRangeOfBlockNumbersToNode()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        address[] memory node = sequencer.getRangeOfBlockNumbersToNode(
            block.number,
            startBlockNumber - 1
        );

        assertEq(node.length, startBlockNumber - block.number);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getNode
    /// -----------------------------------------------------------------------

    function testGetNote()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        INodeSequencer.Node memory node = sequencer.getNode(user);

        assertTrue(node.isActive);
        assertEq(node.endBlockNumber, startBlockNumber - 1);
    }

    /// -----------------------------------------------------------------------
    /// Test for: getCurrentNode
    /// -----------------------------------------------------------------------

    function testGetCurrentNode()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        vm.roll(block.number + 1);
        uint256 startBlockNumber = sequencer.getStartBlockNumber();
        (address nodeAddress, INodeSequencer.Node memory node) = sequencer
            .getCurrentNode();

        assertEq(nodeAddress, user);
        assertTrue(node.isActive);
        assertEq(node.endBlockNumber, startBlockNumber - 1);
    }

    /// -----------------------------------------------------------------------
    /// Test for: isCurrentNode
    /// -----------------------------------------------------------------------

    function testIsCurrentNode()
        public
        mintAndApproveDuh(user, INITIAL_DUH_MINT)
        registerNode(user)
    {
        vm.roll(block.number + 1);
        bool isCurrNode = sequencer.isCurrentNode(user);

        assertTrue(isCurrNode);
    }
}
