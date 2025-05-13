
## 📘 README — ERC20 StakingPool (FlatRate Reward Model)

### 🔐 Overview

This project implements a secure and gas-efficient **ERC20 staking pool** with a **flat-rate reward strategy**. Users stake a token and earn rewards linearly over time. The reward emission rate is fixed and configured at deployment via the `FlatRateRewardStrategy`.

> 🛠 Built using **Foundry** only — no Hardhat, no OpenZeppelin, no external dependencies.

---

## ✨ Features

* 🧱 Flat-rate reward distribution per second
* 🔐 Reentrancy-safe, access-controlled, and gas-optimized
* 🧪 Fully unit-tested with `forge test`
* 💡 Includes a minimal in-project `MockERC20` (in `script/`) for testing
* 🧰 Uses a safe low-level ERC20 wrapper (`SafeERC20`)

---

## 🧠 Reward Formula

```solidity
reward = (stakedAmount * elapsedTime * rewardRatePerSecond) / 1e18
```

Where:

* `rewardRatePerSecond` is set on `FlatRateRewardStrategy` constructor
* Time is based on `block.timestamp - lastUpdate`
* All calculations use 18 decimals scaling

---



## ⚙️ Setup

### 1. Install Foundry (if not yet)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Compile Contracts

```bash
forge compile
```

### 3. Run Tests

```bash
forge test -vvvv
```

---

## 🚀 Deployment (via Foundry script)

Use this command to deploy `MockERC20`, `FlatRateRewardStrategy`, and `StakingPool` locally or on testnet:

```bash
forge script script/DeployStakingPool.s.sol --broadcast --rpc-url <your_rpc_url> --private-key <your_private_key>
```

---

## 🧪 Example Test Output

```bash
[PASS] testClaimRewardsAfterTime() (gas: 145496)
[PASS] testStakeAndUnstakeFlow()
[PASS] testMultipleStakesUpdatesRewards()
...
```

---

## 🔐 Security

* ✅ Reentrancy guard on external entry points
* ✅ Custom errors reduce gas cost on failure
* ✅ Uses `SafeERC20` to prevent transfer/transferFrom issues with broken tokens (e.g., USDT)
