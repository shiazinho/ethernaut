// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HuffDeployer} from "@foundry-huff/HuffDeployer.sol";

contract Deployer is Script {
    string public constant DENIAL_HUFF_LOCATION = "Denial";

    function run() external {
	    IExploiter addr = IExploiter(HuffDeployer.config().deploy(DENIAL_HUFF_LOCATION));
        console.log("Exploiter: ", address(addr));
    }
}

interface IExploiter {}