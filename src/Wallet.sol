// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Wallet is Ownable {
    address public withdrawAddress;
    uint256 public withdrawTime;
    uint256 public lockPeriod;

    uint256 public constant MIN_LOCK_PERIOD = 1 days;

    constructor() Ownable(msg.sender) {
        withdrawAddress = address(msg.sender);
        withdrawTime = block.timestamp;
        lockPeriod = MIN_LOCK_PERIOD;
    }

    receive() external payable {}

    modifier checkWithdraw() {
        require(withdrawAddress != address(0), "Invalid withdraw address");
        require(withdrawTime > 0, "Withdraw locked");
        require(block.timestamp >= withdrawTime, "Invalid withdraw time");
        _;
    }

    modifier updateWithdrawTime() {
        _;
        if (withdrawTime > 0) {
            uint256 nextWithdrawTime = block.timestamp + lockPeriod;
            if (nextWithdrawTime > withdrawTime) {
                withdrawTime = nextWithdrawTime;
            }
        }
    }

    function withdraw(uint256 value) public onlyOwner checkWithdraw {
        payable(withdrawAddress).transfer(value);
    }

    function withdrawToken(address token, uint256 value) public onlyOwner checkWithdraw {
        ERC20(token).transfer(withdrawAddress, value);
    }

    function withdrawTokenWithDecimals(address token, uint256 value) public {
        withdrawToken(token, value * 10 ** ERC20(token).decimals());
    }

    function withdrawTokenAll(address token) public {
        withdrawToken(token, ERC20(token).balanceOf(address(this)));
    }

    function setWithdrawAddress(address newWithdrawAddress) public onlyOwner updateWithdrawTime {
        withdrawAddress = newWithdrawAddress;
    }

    function lockWithdraw() public onlyOwner {
        withdrawTime = 0;
    }

    function unlockWithdraw() public onlyOwner {
        require(withdrawTime == 0);
        withdrawTime = block.timestamp + lockPeriod;
    }

    function setWithdrawTime(uint256 newWithdrawTime) public onlyOwner {
        require(newWithdrawTime >= withdrawTime);
        withdrawTime = newWithdrawTime;
    }

    function setLockPeriod(uint256 newLockPeriod) public onlyOwner updateWithdrawTime {
        require(newLockPeriod >= MIN_LOCK_PERIOD);
        lockPeriod = newLockPeriod;
    }
}
