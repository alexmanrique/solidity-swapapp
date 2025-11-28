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

    function testSwapHistoryIsRecorded() public {
        vm.startPrank(user);
        uint256 amountIn = 5 * 1e6;
        uint256 amountOutMin = 4 * 1e18;
        IERC20(USDT).approve(address(app), amountIn);
        uint256 deadline = block.timestamp + 1000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        // Verificar que inicialmente no hay swaps
        assert(app.getUserSwapCount(user) == 0);

        // Realizar el swap
        app.swapTokens(amountIn, amountOutMin, path, deadline);

        // Verificar que el contador se incrementó
        assert(app.getUserSwapCount(user) == 1);

        // Obtener el historial
        SwapApp.SwapInfo[] memory history = app.getUserSwapHistory(user);
        assert(history.length == 1);

        // Verificar los datos del swap guardado
        assert(history[0].tokenIn == USDT);
        assert(history[0].tokenOut == DAI);
        assert(history[0].amountIn == amountIn);
        assert(history[0].amountOut > 0);
        assert(history[0].path.length == 2);
        assert(history[0].path[0] == USDT);
        assert(history[0].path[1] == DAI);
        assert(history[0].deadline == deadline);
        assert(history[0].timestamp > 0);

        vm.stopPrank();
    }

    function testGetUserSwapAtIndex() public {
        vm.startPrank(user);
        uint256 amountIn = 5 * 1e6;
        uint256 amountOutMin = 4 * 1e18;
        IERC20(USDT).approve(address(app), amountIn);
        uint256 deadline = block.timestamp + 1000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        // Realizar el swap
        app.swapTokens(amountIn, amountOutMin, path, deadline);

        // Obtener el swap por índice
        SwapApp.SwapInfo memory swapInfo = app.getUserSwapAtIndex(user, 0);
        assert(swapInfo.tokenIn == USDT);
        assert(swapInfo.tokenOut == DAI);
        assert(swapInfo.amountIn == amountIn);

        vm.stopPrank();
    }

    function testGetUserSwapAtIndexRevertsOnInvalidIndex() public {
        vm.startPrank(user);
        
        // Intentar obtener un swap cuando no hay ninguno
        vm.expectRevert("SwapApp: index out of bounds");
        app.getUserSwapAtIndex(user, 0);

        vm.stopPrank();
    }

    function testMultipleSwapsAreRecorded() public {
        vm.startPrank(user);
        uint256 amountIn = 5 * 1e6;
        uint256 amountOutMin = 4 * 1e18;
        IERC20(USDT).approve(address(app), amountIn * 3);
        uint256 deadline = block.timestamp + 1000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        // Realizar primer swap
        app.swapTokens(amountIn, amountOutMin, path, deadline);
        assert(app.getUserSwapCount(user) == 1);

        // Realizar segundo swap
        app.swapTokens(amountIn, amountOutMin, path, deadline);
        assert(app.getUserSwapCount(user) == 2);

        // Realizar tercer swap
        app.swapTokens(amountIn, amountOutMin, path, deadline);
        assert(app.getUserSwapCount(user) == 3);

        // Verificar que todos los swaps están en el historial
        SwapApp.SwapInfo[] memory history = app.getUserSwapHistory(user);
        assert(history.length == 3);

        // Verificar que cada swap tiene los datos correctos
        for (uint256 i = 0; i < 3; i++) {
            assert(history[i].tokenIn == USDT);
            assert(history[i].tokenOut == DAI);
            assert(history[i].amountIn == amountIn);
        }

        vm.stopPrank();
    }

    function testSwapHistoryIsUserSpecific() public {
        address user2 = address(0x1234);
        vm.deal(user2, 1 ether);
        
        vm.startPrank(user);
        uint256 amountIn = 5 * 1e6;
        uint256 amountOutMin = 4 * 1e18;
        IERC20(USDT).approve(address(app), amountIn);
        uint256 deadline = block.timestamp + 1000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        app.swapTokens(amountIn, amountOutMin, path, deadline);
        assert(app.getUserSwapCount(user) == 1);
        assert(app.getUserSwapCount(user2) == 0);

        vm.stopPrank();
    }
}