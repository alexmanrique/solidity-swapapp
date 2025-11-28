// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IV2Router02} from "./interfaces/IV2Router02.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {
    using SafeERC20 for IERC20;
    address public V2Router02Address;

    struct SwapInfo {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        address[] path;
        uint256 timestamp;
        uint256 deadline;
    }

    mapping(address => SwapInfo[]) public swapHistory;
    mapping(address => uint256) public swapCount;

    event SwapTokens(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address V2Router02_) {
        V2Router02Address = V2Router02_;
    }

    function swapTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, uint256 deadline) external {
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(V2Router02Address, amountIn);
        uint256[] memory amountOuts =
            IV2Router02(V2Router02Address).swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, deadline);

        SwapInfo memory swapInfo = SwapInfo({
            tokenIn: path[0],
            tokenOut: path[path.length - 1],
            amountIn: amountIn,
            amountOut: amountOuts[amountOuts.length - 1],
            path: path,
            timestamp: block.timestamp,
            deadline: deadline
        });

        swapHistory[msg.sender].push(swapInfo);
        swapCount[msg.sender]++;

        emit SwapTokens(msg.sender, path[0], path[path.length - 1], amountIn, amountOuts[amountOuts.length - 1]);
    }

    function getUserSwapHistory(address user) external view returns (SwapInfo[] memory) {
        return swapHistory[user];
    }

    function getUserSwapCount(address user) external view returns (uint256) {
        return swapCount[user];
    }

    function getUserSwapAtIndex(address user, uint256 index) external view returns (SwapInfo memory) {
        require(index < swapHistory[user].length, "SwapApp: index out of bounds");
        return swapHistory[user][index];
    }
}
