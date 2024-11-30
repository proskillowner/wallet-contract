// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Vault {
    address public owner;
    bool public withdrawLocked;
    address public withdrawAddress;
    uint256 public unlockPeriod;
    uint256 public unlockTime;

    uint256 public constant MIN_UNLOCK_PERIOD = 1 days;

    constructor() {
        owner = msg.sender;
        withdrawLocked = true;
        withdrawAddress = address(0);
        unlockPeriod = MIN_UNLOCK_PERIOD;
        unlockTime = 0;
    }

    receive() external payable {}

    fallback() external payable {
        revert();
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier checkWithdraw(address to) {
        require(!withdrawLocked, "Withdraw locked");
        require(withdrawAddress != address(0), "Zero withdraw address");
        require(to == withdrawAddress, "Invalid withdraw address");
        require(unlockTime > 0, "Invalid lock time");
        require(block.timestamp >= unlockTime, "Invalid time");
        _;
    }

    modifier updateUnlockTime() {
        _;
        uint256 updatedUnlockTime = block.timestamp + unlockPeriod;
        if (unlockTime < updatedUnlockTime) {
            unlockTime = updatedUnlockTime;
        }
    }

    function withdrawETH(address payable to, uint256 value) public onlyOwner checkWithdraw(to) {
        require(value <= address(this).balance, "Insufficient balance");
        payable(to).transfer(value);
    }

    function withdrawERC20(address token, address to, uint256 value) public onlyOwner checkWithdraw(to) {
        IERC20 erc20 = IERC20(token);
        value *= 10 ** erc20.decimals();
        require(value <= erc20.balanceOf(address(this)), "Insufficient balance");
        erc20.transfer(to, value);
    }

    function setWithdrawLocked(bool _withdrawLocked) public onlyOwner updateUnlockTime {
        withdrawLocked = _withdrawLocked;
    }

    function setWithdrawAddress(address _withdrawAddress) public onlyOwner updateUnlockTime {
        withdrawAddress = _withdrawAddress;
    }

    function setUnlockPeriod(uint256 _unlockPeriod) public onlyOwner updateUnlockTime {
        require(_unlockPeriod >= MIN_UNLOCK_PERIOD);
        unlockPeriod = _unlockPeriod;
    }

    function setUnlockTime(uint256 _unlockTime) public onlyOwner {
        require(_unlockTime >= unlockTime);
        unlockTime = _unlockTime;
    }
}
