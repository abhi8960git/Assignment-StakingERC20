// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @notice Interface for pluggable reward strategies
interface IRewardStrategy {
    function calculateReward(address user, uint256 staked, uint256 lastUpdate) external view returns (uint256);
}
