// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract CataDidNFT is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    CountersUpgradeable.Counter private _tokenIdCounter;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    mapping(string => uint256) private _did2tokenId;
    mapping(address => uint256[]) private _address2tokenId;

    event MintDid(address creator, address to, uint256 tokenId, string did);
    event TransferDid(address from, address to, uint256 tokenId, string did);

    function getVersion() public pure returns (uint256 version) {
        return 0;
    }

    function initialize() public initializer {
        __ERC721_init("CataDidNFT", "DID");
        __ERC721URIStorage_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _tokenIdCounter.increment();
    }

    function safeMint(address to, string memory uri)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintDid(to, uri);
    }

    function _mintDid(address to, string memory uri) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _setDid(uri, tokenId);
        _setOwner(to, tokenId);
        emit MintDid(msg.sender, to, tokenId, uri);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        address owner = ownerOf(tokenId);
        _rmTokenId(owner, tokenId);
        super._burn(tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable) {
        super._transfer(from, to, tokenId);
        _rmTokenId(from, tokenId);
        _setOwner(to, tokenId);
        emit TransferDid(from, to, tokenId, tokenURI(tokenId));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // about DID
    function _setDid(string memory did, uint256 tokenId) internal virtual {
        require(_did2tokenId[did] == 0, "CataDidNFT: This did already exists.");
        _did2tokenId[did] = tokenId;
    }

    function _setOwner(address owner, uint256 tokenId) internal virtual {
        _address2tokenId[owner].push(tokenId);
    }

    function didOwner(string memory did) public view virtual returns (address) {
        uint256 tokenId = _did2tokenId[did];
        return ownerOf(tokenId);
    }

    function getDids(address owner)
        public
        view
        virtual
        returns (string memory)
    {
        uint256[] memory tokenIds = _address2tokenId[owner];
        string memory dids = "[";
        for (uint256 i = 0; i < tokenIds.length; i++) {
            string memory did = tokenURI(tokenIds[i]);
            if (i != 0) {
                dids = concat(dids, ",");
            }
            dids = concat(dids, '"');
            dids = concat(dids, did);
            dids = concat(dids, '"');
        }
        return concat(dids, "]");
    }

    function mintDid(address to, string memory did) public {
        string memory baseDid = getBaseUri(did);
        uint256[] memory tokenIds = _address2tokenId[msg.sender];
        bool access = false;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            string memory rootDid = tokenURI(tokenIds[i]);
            if (hashCompareWithLengthCheck(baseDid, rootDid)) {
                access = true;
                break;
            }
        }
        require(access, "CataDidNFT: Invalid did.");
        _mintDid(to, did);
    }

    function transferDid(address from, address to, string memory did) public {
        uint256 tokenId = _did2tokenId[did];
        safeTransferFrom(from, to, tokenId);
    }

    function concat(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string.concat(a, b);
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function hashCompareWithLengthCheck(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return
                keccak256(abi.encodePacked(a)) ==
                keccak256(abi.encodePacked(b));
        }
    }

    function getBaseUri(string memory did)
        internal
        pure
        returns (string memory)
    {
        bytes memory strBytes = bytes(did);
        uint256 index = strBytes.length;
        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] == bytes(".")[0]) {
                index = i + 1;
                break;
            }
        }
        return substring(did, index, strBytes.length);
    }

    function _rmTokenId(address owner, uint256 tokenId) internal {
        uint256[] storage tokenIds = _address2tokenId[owner];
        bool finded = false;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (finded) {
                tokenIds[i - 1] = tokenIds[i];
            } else if (tokenIds[i] == tokenId) {
                finded = true;
            }
        }
        tokenIds.pop();
    }
}
