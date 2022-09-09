// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { Liquidity } from "../src/Liquidity.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";

contract LiquidityTest is Test {
    address alice = vm.addr(1);

    address daiWhale = address(0xF977814e90dA44bFA03b6295A0616a897441aceC);
    address wethWale = address(0xee2826453A4Fd5AfeB7ceffeEF3fFA2320081268);

    address daiAddr = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address wethAddr = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    Liquidity liq;

    IERC20 DAI;
    IERC20 WETH;

    function transferFromWhales() internal {
        vm.prank(daiWhale);
        DAI.transfer(alice, 100000 * 1e18);
        vm.prank(wethWale);
        WETH.transfer(alice, 100 * 1e18);
    }

    function setUp() public {
        liq = new Liquidity();
        DAI = IERC20(daiAddr);
        WETH = IERC20(wethAddr);
        transferFromWhales();
    }

    function testInitialBalance() public {
        assertEq(WETH.balanceOf(alice), 100 * 1e18);
        assertEq(DAI.balanceOf(alice), 100000 * 1e18);
    }

    function addLiquidity() public returns (
        uint256 amountA, uint256 amountB, uint256 liquidity
    ) {
        vm.startPrank(alice);
        WETH.approve(address(liq), 100 * 1e18);
        DAI.approve(address(liq), 100000 * 1e18);
        (amountA, amountB, liquidity) =
            liq.addLiquidity(
                wethAddr, daiAddr, 100 * 1e18, 100000 * 1e18
            );
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        // this test assumes price of eth is below $5000
        // later change tests to chainlink oracles to reflect current price
        (uint256 amountA, uint256 amountB, uint256 liquidity) = 
            addLiquidity();

        emit log_uint(amountA);
        emit log_uint(amountB);
        emit log_uint(liquidity);

        assertGt(amountA, 20 * 1e18);
        assertEq(amountB, 100000 * 1e18);
    }
}