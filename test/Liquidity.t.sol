// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { Liquidity } from "../src/Liquidity.sol";
import { Swap } from "../src/Swap.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";
import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";

contract LiquidityTest is Test {
    address alice = vm.addr(1);
    address bella = vm.addr(2);

    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private constant DAI_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;
    address private constant WETH_WHALE = 0xee2826453A4Fd5AfeB7ceffeEF3fFA2320081268;

    address private constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    Liquidity liq;
    Swap swap;

    IERC20 DAI;
    IERC20 WETH;

    function transferFromWhales() internal {
        vm.startPrank(DAI_WHALE);
        DAI.transfer(alice, 50000 * 1e18);
        DAI.transfer(bella, 25000 * 1e18);
        vm.stopPrank();
        vm.startPrank(WETH_WHALE);
        WETH.transfer(alice, 50 * 1e18);
        WETH.transfer(bella, 25 * 1e18);
        vm.stopPrank();
    }

    function setUp() public {
        liq = new Liquidity();
        swap = new Swap();
        DAI = IERC20(DAI_ADDRESS);
        WETH = IERC20(WETH_ADDRESS);
        transferFromWhales();
    }

    function testInitialBalance() public {
        assertEq(WETH.balanceOf(alice), 50 * 1e18);
        assertEq(DAI.balanceOf(alice), 50000 * 1e18);
    }

    function addLiquidity() internal returns (
        uint256 amountA, uint256 amountB, uint256 liquidity
    ) {
        vm.startPrank(alice);
        WETH.approve(address(liq), 50 * 1e18);
        DAI.approve(address(liq), 50000 * 1e18);
        (amountA, amountB, liquidity) =
            liq.addLiquidity(
                WETH_ADDRESS, DAI_ADDRESS, 50 * 1e18, 50000 * 1e18
            );
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        // later change tests to chainlink oracles to reflect current price
        (uint256 amountA, uint256 amountB, uint256 liquidity) = 
            addLiquidity();

        emit log_uint(amountA);
        emit log_uint(amountB);
        emit log_uint(liquidity);

        assertGt(amountA, 20 * 1e18);
        assertEq(amountB, 50000 * 1e18);
        
    }

    function testRemoveLiquidity() public {
        addLiquidity();

        // Simulate user activity with swapping tokens to get trading fees
        vm.startPrank(bella);
        WETH.approve(address(swap), 25 * 1e18);
        DAI.approve(address(swap), 25000 * 1e18);
        swap.swap(WETH_ADDRESS, DAI_ADDRESS, 25 * 1e18, 25000 * 1e18, bella);
        vm.stopPrank();

        vm.prank(alice);
        (uint amountA, uint256 amountB) =
             liq.removeLiquidity(WETH_ADDRESS, DAI_ADDRESS);
        emit log_uint(amountA);
        emit log_uint(amountB);

        assertGt(amountA, 25 * 1e18);
        assertLt(amountB, 50000 * 1e18);
    }
}