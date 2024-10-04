// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./NFTStructs.sol";
import "./NFTChecks.sol";
import "./NFTPayment.sol";

contract NFTMarketPlace is ERC721, ERC721Enumerable, ERC721Pausable, Ownable, ReentrancyGuard {
    using NFTChecks for *;

    uint256 private _nextTokenId;
    mapping(uint256 => NFTStructs.NFT) public nftsForSale;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mintNFT() external onlyOwner whenNotPaused returns (uint256) {
        _nextTokenId += 1;
        uint256 tokenId = _nextTokenId;

        _safeMint(msg.sender, tokenId);

        nftsForSale[tokenId] = NFTStructs.NFT({
            tokenId: tokenId,
            owner: msg.sender,
            price: 0,
            forSale: false
        });

        emit NFTStructs.NFTMinted(tokenId, msg.sender);
        return tokenId;
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external whenNotPaused {
        NFTChecks.checkOwnership(ownerOf(tokenId), msg.sender);
        NFTChecks.checkPriceGreaterThanZero(price);

        NFTStructs.NFT storage nft = nftsForSale[tokenId];
        nft.price = price;
        nft.forSale = true;

        emit NFTStructs.NFTListedForSale(tokenId, price);
    }

    function buyNFT(uint256 tokenId) external payable nonReentrant whenNotPaused {
        NFTChecks.checkNFTForSale(nftsForSale[tokenId]);
        NFTChecks.checkSufficientFunds(nftsForSale[tokenId], msg.value);

        address seller = nftsForSale[tokenId].owner;
        nftsForSale[tokenId].owner = msg.sender;
        nftsForSale[tokenId].forSale = false;

        _transfer(seller, msg.sender, tokenId);
        NFTPayment.handlePayment(seller, msg.value);

        emit NFTStructs.NFTSold(tokenId, msg.sender, nftsForSale[tokenId].price);
    }

    function removeNFTFromSale(uint256 tokenId) external whenNotPaused {
        NFTChecks.checkOwnership(ownerOf(tokenId), msg.sender);

        NFTStructs.NFT storage nft = nftsForSale[tokenId];
        nft.forSale = false;
    }

    function getNFTDetails(uint256 tokenId) external view returns (address owner, uint256 price, bool forSale) {
        NFTStructs.NFT storage nft = nftsForSale[tokenId];
        return (nft.owner, nft.price, nft.forSale);
    }

    // The following functions are overrides required by Solidity.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
