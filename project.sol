// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for ERC20 tokens
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LearningTokenDEX {
    address public admin;
    mapping(address => uint256) public tokenPrices; // Token prices in a base unit

    event TokenSwapped(
        address indexed user,
        address indexed fromToken,
        address indexed toToken,
        uint256 amountIn,
        uint256 amountOut
    );
    event TokenPriceUpdated(address indexed token, uint256 newPrice);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Admin sets token prices
    function setTokenPrice(address token, uint256 price) external onlyAdmin {
        require(price > 0, "Price must be greater than zero");
        tokenPrices[token] = price;
        emit TokenPriceUpdated(token, price);
    }

    // Users swap tokens
    function swapTokens(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) external {
        require(tokenPrices[fromToken] > 0, "Price for fromToken not set");
        require(tokenPrices[toToken] > 0, "Price for toToken not set");
        require(amountIn > 0, "Amount must be greater than zero");

        uint256 fromTokenValue = amountIn * tokenPrices[fromToken];
        uint256 amountOut = fromTokenValue / tokenPrices[toToken];

        require(IERC20(fromToken).transferFrom(msg.sender, address(this), amountIn), "Transfer failed");
        require(IERC20(toToken).transfer(msg.sender, amountOut), "Transfer failed");

        emit TokenSwapped(msg.sender, fromToken, toToken, amountIn, amountOut);
    }
}
