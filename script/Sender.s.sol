// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Sender} from "../src/Sender.sol";

contract DeployScript is Script {
    Sender public sender;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        sender = new Sender();
        vm.stopBroadcast();
    }
}
