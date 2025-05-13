// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {RockPaperScissorsV1} from "../src/RockPaperScissorsV1.sol";

contract DeployRPS is Script {
    function run() external {
        // Load deployer account
        vm.startBroadcast();

        // Deploy contract
        RockPaperScissorsV1 rps = new RockPaperScissorsV1();

        // Initialize contract (since it's upgradeable)
        rps.initialize();

        vm.stopBroadcast();
    }
}
