// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftExchange is Ownable {

    IERC721 private _nftCode;
    uint256 private _minDuration;
    mapping(uint256 => uint256) private _timestamps;
    mapping(uint256 => uint256) private _prices;
    
    event DoneOnShelf(uint256 tokenId, uint256 price, uint256 timestamps);
    event DonePurchase(address from, address to, uint256 tokenId, uint256 price);
    event DoneWithdraw(address to, uint256 amount);

    constructor(IERC721 nftCode, uint256 minDuration)
    {
        _nftCode = nftCode;
        _minDuration = minDuration;
    }

    function getMinDuration() public view returns (uint256 duration) {
        return _minDuration;
    }

    function getNftCode() public view returns (IERC721 nftCode) {
        return _nftCode;
    }

    function getTimestamp(uint256 tokenId) public view returns (uint256 timestamp) {
        return _timestamps[tokenId];
    }

    function getPrices(uint256 tokenId) public view returns (uint256 price) {
        return _prices[tokenId];
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        require(success, "NftExchange: withdraw error!");
        
        emit DoneWithdraw(msg.sender, amount); 
    }

    function sell(uint256 tokenId, uint256 price, uint256 duration) public {
        address owner = _nftCode.ownerOf(tokenId);
        require(msg.sender == owner, "NftExchange: seller is not nft owner");
        require(duration >= getMinDuration(), string(abi.encodePacked("NftExchange: duration at least ", Strings.toString(getMinDuration()))));
        _timestamps[tokenId] = block.timestamp + duration;
        _prices[tokenId] = price;
        emit DoneOnShelf(tokenId, price, _timestamps[tokenId]); 
    }

    function buy(uint256 tokenId) public payable {
        require(block.timestamp <= getTimestamp(tokenId), "NftExchange: nft not on the shelf!");
        uint256 price = _prices[tokenId];
        require(msg.value >= price, string(abi.encodePacked("NftExchange: value Quantity less than ", Strings.toString(getMinDuration()))));
        address from = _nftCode.ownerOf(tokenId);
        _nftCode.safeTransferFrom(from, msg.sender, tokenId);
        _timestamps[tokenId] = 0;

        emit DonePurchase(from, msg.sender, tokenId, price); 
    }
}