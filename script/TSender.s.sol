// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TSender} from "../src/TSender.sol";

contract DeployScript is Script {
    TSender public sender;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        sender = new TSender();
        vm.stopBroadcast();
    }
}
