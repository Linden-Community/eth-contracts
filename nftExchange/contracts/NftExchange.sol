// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftExchange is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant EXADMIN_ROLE = keccak256("EXADMIN_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    IERC721 private _nftCode;
    uint256 private _minDuration;
    uint256 private _maxDuration;
    mapping(uint256 => uint256) private _offShelfTime;
    mapping(uint256 => uint256) private _prices;

    function getVersion() public pure returns (uint256 version) {
        return 5;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // minDuration = 86400
    // maxDuration = 15552000
    function initialize(
        IERC721 nftCode,
        uint256 minDuration,
        uint256 maxDuration
    ) public initializer {
        _nftCode = nftCode;
        _minDuration = minDuration;
        _maxDuration = maxDuration;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXADMIN_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    event DoneOnShelf(
        address owner,
        address nftCode,
        uint256 tokenId,
        uint256 price,
        uint256 timestamps
    );
    event DonePurchase(
        address from,
        address to,
        address nftCode,
        uint256 tokenId,
        uint256 price
    );
    event DoneWithdraw(address to, uint256 amount);

    function setMinDuration(uint256 duration) public onlyRole(EXADMIN_ROLE) {
        require(duration <= 8640000000, "NftExchange: Min duration error!");
        require(duration < getMaxDuration(), "NftExchange: Min duration should be less than the max duration!");
        _minDuration = duration;
    }

    function getMinDuration() public view returns (uint256 duration) {
        return _minDuration;
    }

    function setMaxDuration(uint256 duration) public onlyRole(EXADMIN_ROLE) {
        require(duration <= 8640000000, "NftExchange: Max duration error!");
        require(duration > getMinDuration(), "NftExchange: Max duration should be greater than the min duration!");
        _maxDuration = duration;
    }

    function getMaxDuration() public view returns (uint256 duration) {
        return _maxDuration;
    }

    function setNftCode(IERC721 nftCode) public onlyRole(EXADMIN_ROLE) {
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

    function withdraw(address to, uint256 amount)
        public
        onlyRole(WITHDRAW_ROLE)
    {
        // require(amount <= address(this).balance, "NftExchange: withdraw amount error!");
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
        emit DoneOnShelf(
            owner,
            address(getNftCode()),
            tokenId,
            price,
            _offShelfTime[tokenId]
        );
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
        emit DonePurchase(
            from,
            msg.sender,
            address(getNftCode()),
            tokenId,
            price
        );
    }
}
