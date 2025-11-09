// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {HuffDeployer} from "@foundry-huff/HuffDeployer.sol";

contract Deployer is Script {
    string public constant MAGIC_NUM_HUFF_LOCATION = "MagicNum";

    function run() external {
	    IMagicNum(HuffDeployer.config().deploy(MAGIC_NUM_HUFF_LOCATION));
    }
}

interface IMagicNum {
    function whatIsTheMeaningOfLife() external view returns (uint256);
}
