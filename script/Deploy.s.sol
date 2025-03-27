// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Wallet.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address owner = vm.envAddress("OWNER");

        Wallet wallet = new Wallet(owner);
        console.log("Wallet address =>", address(wallet));

        vm.stopBroadcast();
    }
}
