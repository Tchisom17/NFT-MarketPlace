// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library NFTPayment {
    // Custom error
    error TransferFailed();

    function handlePayment(address seller, uint256 value) internal {
        (bool success, ) = payable(seller).call{value: value}("");
        if (!success) {
            revert TransferFailed();
        }
    }
}
