// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;

    receive() external payable {}

    function setUp() public {
        vault = new Vault();
    }

    function testVault() public {
        uint256 currentTime = block.timestamp;
        console.log("Current time:", currentTime);
        vault.setWithdrawLocked(false);
        vault.setWithdrawAddress(address(this));

        uint256 unlockTime = vault.unlockTime();
        console.log("Unlock time:", unlockTime);
        vm.warp(unlockTime);

        vault.withdrawETH(payable(address(this)), 0);
        console.log("Withdraw success");
    }
}
