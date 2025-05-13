// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../interfaces/IRewardStrategy.sol";

contract FlatRateRewardStrategy is IRewardStrategy {
    uint256 public immutable ratePerSecond;

    constructor(uint256 _ratePerSecond) {
        ratePerSecond = _ratePerSecond;
    }

    function calculateReward(address, uint256 staked, uint256 lastUpdate) external view override returns (uint256) {
        uint256 duration = block.timestamp - lastUpdate;
        return (staked * duration * ratePerSecond) / 1e18;
    }
}
