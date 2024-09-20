// // SPDX-License-Identifier: MIT
// // Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketPlace is ERC721, ERC721Enumerable, ERC721Pausable, Ownable, ReentrancyGuard {
    uint256 private _nextTokenId;
    // uint256 public constant mintPrice = 1 ether;

    struct NFT {
        uint256 tokenId;
        address owner;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => NFT) public nftsForSale;

    event NFTMinted(uint256 indexed tokenId, address indexed owner);
    event NFTListedForSale(uint256 indexed tokenId, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

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

        nftsForSale[tokenId] = NFT({
            tokenId: tokenId,
            owner: msg.sender,
            price: 0,
            forSale: false
        });

        emit NFTMinted(tokenId, msg.sender);
        return tokenId;
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external whenNotPaused {
        require(ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");
        require(price > 0, "Price must be greater than 0");

        NFT storage nft = nftsForSale[tokenId];
        nft.price = price;
        nft.forSale = true;

        emit NFTListedForSale(tokenId, price);
    }

    function buyNFT(uint256 tokenId) external payable nonReentrant whenNotPaused {
        NFT storage nft = nftsForSale[tokenId];
        require(nft.forSale, "NFT not for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address seller = nft.owner;
        nft.owner = msg.sender;
        nft.forSale = false;
        
        _transfer(seller, msg.sender, tokenId);
        (bool success, ) = payable(seller).call{value: msg.value}("");
        require(success, "Transfer failed!");

        emit NFTSold(tokenId, msg.sender, nft.price);
    }

    function removeNFTFromSale(uint256 tokenId) external whenNotPaused {
        require(ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");

        NFT storage nft = nftsForSale[tokenId];
        nft.forSale = false;
    }

    function getNFTDetails(uint256 tokenId) external view returns (address owner, uint256 price, bool forSale) {
        NFT storage nft = nftsForSale[tokenId];
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
