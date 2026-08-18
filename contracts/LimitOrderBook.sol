// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LimitOrderBook is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    struct Order {
        address maker;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        bool isFilled;
    }

    uint256 public nextOrderId = 1;
    mapping(uint256 => Order) public orders;

    event OrderCreated(uint256 indexed orderId, address indexed maker, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event OrderExecuted(uint256 indexed orderId, address executor);
    event OrderCanceled(uint256 indexed orderId);

    constructor() Ownable(msg.sender) {}

    function createOrder(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOut
    ) external nonReentrant returns (uint256 orderId) {
        require(_amountIn > 0, "Amount must be > 0");
        require(_tokenIn != address(0) && _tokenOut != address(0), "Invalid tokens");

        IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);

        orderId = nextOrderId;
        orders[orderId] = Order({
            maker: msg.sender,
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            amountIn: _amountIn,
            amountOut: _amountOut,
            isFilled: false
        });

        nextOrderId++;

        emit OrderCreated(orderId, msg.sender, _tokenIn, _tokenOut, _amountIn, _amountOut);
    }

    function executeOrder(
        uint256 _orderId,
        bytes calldata _dexCalldata
    ) external nonReentrant {
        Order storage order = orders[_orderId];
        require(!order.isFilled, "Order already filled");
        require(order.maker != address(0), "Order does not exist");
        
        // ==========================================
        // TODO: START OF BLOCK FOR ANOTHER DEVELOPER
        // ==========================================
        
        // 1. Approve DEX aggregator to spend order.tokenIn
        // 2. Call DEX aggregator with _dexCalldata
        // 3. Check received amount of order.tokenOut
        // 4. Verify receivedAmount >= order.amountOut

        // ==========================================
        // TODO: END OF BLOCK FOR ANOTHER DEVELOPER
        // ==========================================

        order.isFilled = true;

        uint256 receivedAmount = 0; // Placeholder
        require(receivedAmount > 0, "Received 0 tokens");

        IERC20(order.tokenOut).safeTransfer(order.maker, receivedAmount);

        emit OrderExecuted(_orderId, msg.sender);
    }

    function cancelOrder(uint256 _orderId) external nonReentrant {
        Order storage order = orders[_orderId];
        require(msg.sender == order.maker, "Not your order");
        require(!order.isFilled, "Already filled");

        order.isFilled = true; 

        IERC20(order.tokenIn).safeTransfer(order.maker, order.amountIn);

        emit OrderCanceled(_orderId);
    }
}
