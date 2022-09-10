// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { FlashSwap } from "../src/FlashSwap.sol";

contract FlashSwapTest is Test {
    FlashSwap fs;
    function setUp() public {
        fs = new FlashSwap();
    }
}