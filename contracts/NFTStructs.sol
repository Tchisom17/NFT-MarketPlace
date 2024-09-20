// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library NFTStructs {
    struct NFT {
        uint256 tokenId;
        address owner;
        uint256 price;
        bool forSale;
    }

    // Events
    event NFTMinted(uint256 indexed tokenId, address indexed owner);
    event NFTListedForSale(uint256 indexed tokenId, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);
}
