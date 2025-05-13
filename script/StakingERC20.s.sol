// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import {MockERC20} from "../src/utils/MockERC20.sol";
import {FlatRateRewardStrategy} from "../src/utils/FlatRateRewardStrategy.sol";
import {StakingPool} from "../src/StakingERC20.sol";

contract DeployStakingPool is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Deploy mock token (replace with real ERC20 if deploying to live net)
        MockERC20 token = new MockERC20("StakeToken", "STK", 18);

        // 2. Deploy reward strategy
        FlatRateRewardStrategy strategy = new FlatRateRewardStrategy(1e12); // 0.000001 token/sec per token
        // 3. Deploy staking pool
        StakingPool pool = new StakingPool(address(token), address(strategy));
        console.log("Deployed StakeToken at:", address(token));
        console.log("Deployed Strategy at:", address(strategy));
        console.log("Deployed StakingPool at:", address(pool));

        vm.stopBroadcast();
    }
}
