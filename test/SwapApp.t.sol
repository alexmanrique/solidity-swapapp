// SPDX-License-Identifier: MIT
// forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc
pragma solidity ^0.8.30;

import "../lib/forge-std/src/Test.sol";
import {SwapApp} from "../src/SwapApp.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SwapAppTest is Test {
    SwapApp app;
    address uniswapV2SwappRouterAddress = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address user = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1; // Address with USDT in Arbitrum Mainnet
    address USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9; // USDT address in Arbitrum Mainnet
    address DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1; // DAI address in Arbitrum Mainnet

    function setUp() public {
        app = new SwapApp(uniswapV2SwappRouterAddress);
    }

    function testHasBeenDeployedCorrectly() public view {
        assert(app.V2Router02Address() == uniswapV2SwappRouterAddress);
    }

    function testSwapTokensCorrectly() public {
        vm.startPrank(user);
        uint256 amountIn = 5 * 1e6;
        uint256 amountOutMin = 4 * 1e18;
        IERC20(USDT).approve(address(app), amountIn);
        uint256 deadline = 1738499328 + 1000000000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        uint256 usdtBalanceBefore = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceBefore = IERC20(DAI).balanceOf(user);
        app.swapTokens(amountIn, amountOutMin, path, deadline);
        uint256 usdtBalanceAfter = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceAfter = IERC20(DAI).balanceOf(user);

        assert(usdtBalanceAfter == usdtBalanceBefore - amountIn);
        assert(daiBalanceAfter > daiBalanceBefore);

        vm.stopPrank();
    }
}
