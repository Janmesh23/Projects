// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Staking is AccessControl, ReentrancyGuard {
    MetaToken public token;
    uint256 public rewardRate = 1e16; // 1% per block
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastStakedTime;

    constructor(address _token) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        token = MetaToken(_token);
    }

    function stake(uint256 amount) external nonReentrant {
        token.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        lastStakedTime[msg.sender] = block.timestamp;
    }

    function unstake(uint256 amount) external nonReentrant {
        require(stakedBalance[msg.sender] >= amount, "Insufficient stake");
        _calculateReward(msg.sender);
        stakedBalance[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function claimReward() external nonReentrant {
        uint256 reward = _calculateReward(msg.sender);
        token.mint(msg.sender, reward);
    }

    function _calculateReward(address user) internal returns (uint256) {
        uint256 duration = block.timestamp - lastStakedTime[user];
        uint256 reward = stakedBalance[user] * rewardRate * duration / 1e18;
        lastStakedTime[user] = block.timestamp;
        return reward;
    }
}