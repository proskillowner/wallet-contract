// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "forge-std/Test.sol";
import "../src/Wallet.sol";

contract USDT is ERC20 {
    constructor() ERC20("Tether USD", "USDT") {}

    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}

contract WalletTest is Test {
    Wallet public wallet;

    USDT public usdt;

    address owner = address(1);
    address withdrawAddress = address(2);

    receive() external payable {}

    function setUp() public {
        vm.startPrank(owner);

        wallet = new Wallet(owner);

        usdt = new USDT();

        vm.stopPrank();
    }

    function testwallet() public {
        vm.deal(owner, 10);

        usdt.mint(owner, 10);

        vm.startPrank(owner);

        {
            payable(wallet).transfer(10);

            assertEq(address(wallet).balance, 10);

            usdt.transfer(address(wallet), 10);

            assertEq(usdt.balanceOf(address(wallet)), 10);
        }

        {
            wallet.setWithdrawAddress(address(0));

            vm.warp(wallet.withdrawTime());

            vm.expectRevert();
            wallet.withdraw(10);

            vm.expectRevert();
            wallet.withdrawToken(address(usdt), 10);

            wallet.setWithdrawAddress(withdrawAddress);
        }

        {
            wallet.lockWithdraw();

            vm.expectRevert();
            wallet.withdraw(10);

            vm.expectRevert();
            wallet.withdrawToken(address(usdt), 10);

            wallet.unlockWithdraw();
        }

        {
            vm.expectRevert();
            wallet.withdraw(10);

            vm.expectRevert();
            wallet.withdrawToken(address(usdt), 10);

            vm.warp(wallet.withdrawTime());

            wallet.withdraw(10);

            assertEq(withdrawAddress.balance, 10);

            wallet.withdrawToken(address(usdt), 10);

            assertEq(usdt.balanceOf(withdrawAddress), 10);
        }

        vm.stopPrank();
    }
}
