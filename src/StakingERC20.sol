// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IRewardStrategy} from "./interfaces/IRewardStrategy.sol";
import {SafeERC20} from "./utils/safeERC20.sol";

/// @notice Minimal ERC20 interface
interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

/// @title StakingPool
/// @author Abhishek
/// @notice Staking contract with pluggable reward logic and SafeERC20 transfers

contract StakingPool{
    /// -----------------------------------------------------------------------
    /// Custom Errors
    /// -----------------------------------------------------------------------
    error ZeroAmount();
    error NotAdmin();
    error TransferFailed();
    error InsufficientBalance();
    error ReentrantCall();
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
   
    /// -----------------------------------------------------------------------
    /// Storage
    /// -----------------------------------------------------------------------

    IERC20 public immutable stakingToken;
    IRewardStrategy public immutable rewardStrategy;
    address public immutable admin;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastUpdate;
    mapping(address => uint256) public rewards;

    uint256 private unlocked = 1;

      /// -----------------------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------------------

    modifier nonReentrant() {
        if (unlocked != 1) revert ReentrantCall();
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

     /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /**
     * @notice Deploys staking pool with specified ERC20 and reward strategy
     * @param _token ERC20 token to stake
     * @param _strategy Reward logic contract
     */
    constructor(address _token, address _strategy) {
        if (_token == address(0) || _strategy == address(0)) revert ZeroAmount();
        stakingToken = IERC20(_token);
        rewardStrategy = IRewardStrategy(_strategy);
        admin = msg.sender;
    }

     /// -----------------------------------------------------------------------
    /// External Functions
    /// -----------------------------------------------------------------------

    /**
     * @notice Stake tokens
     * @param amount Amount of tokens to stake
     */
    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        _updateRewards(msg.sender);

        stakedBalance[msg.sender] += amount;
        lastUpdate[msg.sender] = block.timestamp;

        SafeERC20.safeTransferFrom(address(stakingToken), msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

     /**
     * @notice Unstake tokens
     * @param amount Amount to withdraw
     */
    function unstake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (stakedBalance[msg.sender] < amount) revert InsufficientBalance();

        _updateRewards(msg.sender);

        stakedBalance[msg.sender] -= amount;
        lastUpdate[msg.sender] = block.timestamp;

        SafeERC20.safeTransfer(address(stakingToken), msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

     /**
     * @notice Claim accumulated rewards
     */
    function claimRewards() external nonReentrant {
        _updateRewards(msg.sender);

        uint256 reward = rewards[msg.sender];
        if (reward == 0) revert ZeroAmount();
        rewards[msg.sender] = 0;

        SafeERC20.safeTransfer(address(stakingToken), msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }


       /**
     * @notice Admin can fund reward pool
     * @param amount Tokens to fund
     */
    function fundRewards(uint256 amount) external onlyAdmin {
        if (amount == 0) revert ZeroAmount();
        SafeERC20.safeTransferFrom(address(stakingToken), msg.sender, address(this), amount);
    }

     /// -----------------------------------------------------------------------
    /// Internal Functions
    /// -----------------------------------------------------------------------

    /**
     * @dev Update reward state for user
     * @param user Target address
     */
    function _updateRewards(address user) internal {
        uint256 staked = stakedBalance[user];
        uint256 last = lastUpdate[user];

        if (staked == 0) {
            lastUpdate[user] = block.timestamp;
            return;
        }

        uint256 reward = rewardStrategy.calculateReward(user, staked, last);
        rewards[user] += reward;
        lastUpdate[user] = block.timestamp;
    }

}