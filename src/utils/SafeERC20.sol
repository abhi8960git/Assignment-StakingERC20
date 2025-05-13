// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @notice Safe ERC20 wrapper for raw low-level calls, compatible with broken/non-standard tokens
library SafeERC20 {
    function safeTransfer(address token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), to, amount)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)")), from, to, amount)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: TRANSFER_FROM_FAILED");
    }
}
