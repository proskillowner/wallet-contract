// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Wallet.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        Wallet wallet = new Wallet();
        console.log("Wallet address =>", address(wallet));

        vm.stopBroadcast();
    }
}
