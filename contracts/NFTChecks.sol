// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFTStructs.sol";

library NFTChecks {
    // Custom error definitions
    error NotOwnerOfNFT();
    error PriceMustBeGreaterThanZero();
    error NFTNotForSale();
    error InsufficientFunds();

    function checkOwnership(address owner, address sender) internal pure {
        if (owner != sender) {
            revert NotOwnerOfNFT();
        }
    }

    function checkPriceGreaterThanZero(uint256 price) internal pure {
        if (price <= 0) {
            revert PriceMustBeGreaterThanZero();
        }
    }

    function checkNFTForSale(NFTStructs.NFT storage nft) internal view {
        if (!nft.forSale) {
            revert NFTNotForSale();
        }
    }

    function checkSufficientFunds(NFTStructs.NFT storage nft, uint256 value) internal view {
        if (value < nft.price) {
            revert InsufficientFunds();
        }
    }
}
