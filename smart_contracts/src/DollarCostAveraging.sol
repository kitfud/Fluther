// SPDX-License-Identifier: UNLICENSED
// This code is proprietary and confidential. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary code by Levi Webb

pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

contract DollarCostAverage {
    struct RecurringBuys {
        address sender;
        uint256 amount;
        address token1;
        address token2;
        uint256 timeIntervalSeconds;
        address paymentInterface;
        string[] additionalInformation;
        uint256 paymentDue;
        bool canceled;
    }

    RecurringBuys[] public recurringBuys;

    event RecurringBuyCreated(
        address indexed sender,
        uint256 amount,
        address token1,
        address token2,
        uint256 timeIntervalSeconds,
        address indexed paymentInterface,
        string[] additionalInformation,
        uint256 paymentDue,
        bool canceled
    );
    event RecurringBuyCancelled(uint256 indexed index, address indexed sender);
    event PaymentTransferred(uint256 indexed index);

    address public owner;
    uint256 public totalPayments;
    address public duh;
    uint256 public minimumDuh;
    address public _uniswapRouterAddress =
        0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    mapping(address => uint256[]) addressToIndices;

    constructor() {
        owner = msg.sender;
        minimumDuh = 0;
        duh = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }

    modifier hasSufficientTokens() {
        require(
            IERC20(duh).balanceOf(tx.origin) >= minimumDuh,
            "Insufficient token balance."
        );
        _;
    }

    function createRecurringBuy(
        uint256 _amount,
        address _token1,
        address _token2,
        uint256 _timeIntervalSeconds,
        address _interface,
        string[] memory _additionalInformation
    ) external {
        require(_amount > 0, "Payment amount must be greater than zero");
        address _sender = msg.sender;
        totalPayments++;
        uint256 paymentDue = block.timestamp;

        RecurringBuys memory buy = RecurringBuys(
            _sender,
            _amount,
            _token1,
            _token2,
            _timeIntervalSeconds,
            _interface,
            _additionalInformation,
            paymentDue,
            false
        );
        recurringBuys.push(buy);

        addressToIndices[_sender].push(recurringBuys.length - 1);

        addressToIndices[_interface].push(recurringBuys.length - 1);
        addressToIndices[_token1].push(recurringBuys.length - 1);

        emit RecurringBuyCreated(
            _sender,
            _amount,
            _token1,
            _token2,
            _timeIntervalSeconds,
            _interface,
            _additionalInformation,
            paymentDue,
            false
        );
    }

    function transferFunds(uint256 index) external hasSufficientTokens {
        require(index < totalPayments, "Invalid payment index");

        RecurringBuys storage buy = recurringBuys[index];
        require(!buy.canceled, "The recurring payment has been canceled.");

        require(
            block.timestamp >= buy.paymentDue,
            "Not enough time has passed since the last transfer."
        );
        buy.paymentDue += buy.timeIntervalSeconds;

        emit PaymentTransferred(index);

        uint256 buyAmount = (buy.amount * 990) / 1000;
        uint256 fee = buy.amount - buyAmount;
        uint256 interfaceFee = fee / 3;
        uint256 callerFee = fee / 3;
        uint256 contractFee = fee - interfaceFee - callerFee;

        // Transfer the tokens
        require(
            IERC20(buy.token1).transferFrom(
                buy.sender,
                address(this),
                buyAmount
            ),
            "Token transfer failed."
        );
        require(
            IERC20(buy.token1).transferFrom(
                buy.sender,
                buy.paymentInterface,
                contractFee
            ),
            "contract fee Token transfer failed."
        );
        require(
            IERC20(buy.token1).transferFrom(buy.sender, msg.sender, callerFee),
            "caller fee Token transfer failed."
        );
        require(
            IERC20(buy.token1).transferFrom(buy.sender, owner, contractFee),
            "contract fee Token transfer failed."
        );

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(
            _uniswapRouterAddress
        );

        IERC20(buy.token1).approve(_uniswapRouterAddress, buyAmount);

        address[] memory path;
        if (buy.token1 == WMATIC || buy.token2 == WMATIC) {
            path = new address[](2);
            path[0] = buy.token1;
            path[1] = buy.token2;
        } else {
            path = new address[](3);
            path[0] = buy.token1;
            path[1] = WMATIC;
            path[2] = buy.token2;
        }

        uint256[] memory getAmountsOut = uniswapRouter.getAmountsOut(
            buyAmount,
            path
        );

       //uint256 amountOutMin = (getAmountsOut[0] * 99) / 100;
       uint256 amountOutMin = getAmountsOut[getAmountsOut.length - 1]*99/1000;

        uniswapRouter.swapExactTokensForTokens(
            buyAmount,
            amountOutMin,
            path,
            buy.sender,
            block.timestamp
        );
    }

    function getCurrentBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function getPaymentDue(uint256 index) external view returns (uint256) {
        require(index < totalPayments, "Invalid payment index");

        RecurringBuys storage payment = recurringBuys[index];

        return payment.paymentDue;
    }

    function cancelRecurringPayment(uint256 index) external {
        require(index < totalPayments, "Invalid payment index");

        RecurringBuys storage buy = recurringBuys[index];

        require(
            msg.sender == buy.sender,
            "Only the payment sender or recipient can cancel the recurring payment."
        );

        buy.canceled = true;

        emit RecurringBuyCancelled(index, buy.sender);
    }

    function getRecurringPaymentIndices(address account)
        external
        view
        returns (uint256[] memory)
    {
        return addressToIndices[account];
    }

    function isSubscriptionValid(uint256 index) external view returns (bool) {
        require(index < totalPayments, "Invalid payment index");

        RecurringBuys storage buy = recurringBuys[index];

        uint256 oneDayInSeconds = 24 * 60 * 60; // Number of seconds in a day

        return buy.paymentDue + oneDayInSeconds > block.timestamp;
    }

    function isPaymentCanceled(uint256 index) external view returns (bool) {
        require(index < totalPayments, "Invalid payment index");

        RecurringBuys storage payment = recurringBuys[index];

        return payment.canceled;
    }

    function getAdditionalInformation(uint256 index)
        external
        view
        returns (string[] memory)
    {
        require(index < totalPayments, "Invalid payment index");

        RecurringBuys storage buy = recurringBuys[index];

        return buy.additionalInformation;
    }

    function updateMinimumDuh(uint256 _minimumDuh) external onlyOwner {
        minimumDuh = _minimumDuh;
    }

    function setDuhAddress(address tokenAddress) external onlyOwner {
        duh = tokenAddress;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");

        owner = newOwner;
    }
}