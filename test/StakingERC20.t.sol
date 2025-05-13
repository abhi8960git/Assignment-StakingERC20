// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/utils/MockERC20.sol";
import "../src/utils/FlatRateRewardStrategy.sol";
import "../src/StakingERC20.sol";

contract CounterTest is Test {
    MockERC20 public token;
    FlatRateRewardStrategy public strategy;
    StakingPool public pool;

    address public admin;
    address public user;

    function setUp() public {
        admin = address(this);
        user = address(0xBEEF);

        // Deploy mock token and mint
        token = new MockERC20("StakeToken", "STK", 18);
        token.mint(admin, 1_000 ether);
        token.mint(user, 1_000 ether);

        // Deploy reward strategy: 0.000001 token/sec per token
        strategy = new FlatRateRewardStrategy(1e12);

        // Deploy staking pool
        pool = new StakingPool(address(token), address(strategy));

        // Approve staking pool from both accounts
        token.approve(address(pool), type(uint256).max);
        vm.prank(user);
        token.approve(address(pool), type(uint256).max);
    }

    function testStakeAndUnstakeFlow() public {
        vm.prank(user);
        pool.stake(100 ether);
        assertEq(pool.stakedBalance(user), 100 ether);

        skip(10); // simulate 10 seconds

        vm.prank(user);
        pool.unstake(100 ether);

        assertEq(pool.stakedBalance(user), 0);
        uint256 finalBal = token.balanceOf(user);
        assertGt(finalBal, 100 ether); // includes reward
    }

    function testClaimRewardsAfterTime() public {
        vm.startPrank(user);
        pool.stake(200 ether);
        skip(15); //simulate for 15s
        uint256 beforeBalance = token.balanceOf(user);
        pool.claimRewards();
        uint256 afterBalance = token.balanceOf(user);
        uint256 reward = afterBalance - beforeBalance;

        uint256 expected = (200 ether * 15 * 1e12) / 1e18;
        assertApproxEqAbs(reward, expected, 1);

        vm.stopPrank();
    }
}
