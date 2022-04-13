// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftExchange is Ownable {
    IERC721 private _nftCode;
    uint256 private _minDuration;
    uint256 private _maxDuration;
    mapping(uint256 => uint256) private _offShelfTime;
    mapping(uint256 => uint256) private _prices;

    event DoneOnShelf(
        address owner,
        uint256 tokenId,
        uint256 price,
        uint256 timestamps
    );
    event DonePurchase(
        address from,
        address to,
        uint256 tokenId,
        uint256 price
    );
    event DoneWithdraw(address to, uint256 amount);

    // minDuration = 86400
    // maxDuration = 15552000
    constructor(
        IERC721 nftCode,
        uint256 minDuration,
        uint256 maxDuration
    ) {
        _nftCode = nftCode;
        _minDuration = minDuration;
        _maxDuration = maxDuration;
    }

    function setMinDuration(uint256 duration) public onlyOwner {
        _minDuration = duration;
    }

    function getMinDuration() public view returns (uint256 duration) {
        return _minDuration;
    }

    function setMaxDuration(uint256 duration) public onlyOwner {
        _maxDuration = duration;
    }

    function getMaxDuration() public view returns (uint256 duration) {
        return _maxDuration;
    }

    function setNftCode(IERC721 nftCode) public onlyOwner {
        _nftCode = nftCode;
    }

    function getNftCode() public view returns (IERC721 nftCode) {
        return _nftCode;
    }

    function getOffShelfTime(uint256 tokenId)
        public
        view
        returns (uint256 offShelfTime)
    {
        return _offShelfTime[tokenId];
    }

    function getPrices(uint256 tokenId) public view returns (uint256 price) {
        return _prices[tokenId];
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        require(success, "NftExchange: withdraw error!");

        emit DoneWithdraw(msg.sender, amount);
    }

    function sell(
        uint256 tokenId,
        uint256 price,
        uint256 offShelfTime
    ) public {
        address owner = _nftCode.ownerOf(tokenId);
        require(msg.sender == owner, "NftExchange: seller is not nft owner");
        require(
            offShelfTime >= getMinDuration() + block.timestamp,
            string(
                abi.encodePacked(
                    "NftExchange: offShelfTime at least  ",
                    Strings.toString(getMinDuration() + block.timestamp)
                )
            )
        );
        uint256 duration = offShelfTime - block.timestamp;
        require(
            duration >= getMinDuration() && duration <= getMaxDuration(),
            string(
                abi.encodePacked(
                    "NftExchange: duration not in ",
                    Strings.toString(getMinDuration()),
                    "-",
                    Strings.toString(getMaxDuration())
                )
            )
        );
        require(price <= 9999999900000000000000, "price max is 9999.9999");
        _offShelfTime[tokenId] = offShelfTime;
        _prices[tokenId] = price;
        emit DoneOnShelf(owner, tokenId, price, _offShelfTime[tokenId]);
    }

    function buy(uint256 tokenId) public payable {
        require(
            block.timestamp <= getOffShelfTime(tokenId),
            "NftExchange: nft not on the shelf!"
        );
        uint256 price = _prices[tokenId];
        require(
            msg.value >= price,
            string(
                abi.encodePacked(
                    "NftExchange: value Quantity less than ",
                    Strings.toString(price)
                )
            )
        );
        address from = _nftCode.ownerOf(tokenId);

        uint256 harvest = (price / 100) * 98;
        (bool success, ) = from.call{value: harvest}("");
        require(success, "NftExchange: payment failure!");
        _nftCode.safeTransferFrom(from, msg.sender, tokenId);

        _offShelfTime[tokenId] = 0;
        emit DonePurchase(from, msg.sender, tokenId, price);
    }
}
