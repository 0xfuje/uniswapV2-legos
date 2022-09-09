// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { Swap } from "../src/Swap.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";

contract SwapTest is Test {
    address whale = address(0xF977814e90dA44bFA03b6295A0616a897441aceC);
    
    address daiAddr = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address wbtcAddr = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    
    Swap swap;
    IERC20 DAI;
    IERC20 WBTC;
    function setUp() public {
        swap = new Swap();
        DAI = IERC20(daiAddr);
        WBTC = IERC20(wbtcAddr);
    }

    function testSwap() public {
        vm.startPrank(whale);
        uint amountIn = 1000000 * 1e18;
        DAI.approve(address(swap), amountIn);
        swap.swap(
            daiAddr,
            wbtcAddr,
            amountIn,
            10,
            whale
        );
        emit log_uint(WBTC.balanceOf(whale) / 1e8);
        vm.stopPrank(); 
    }
}
