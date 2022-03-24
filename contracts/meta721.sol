// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract METANFT is ERC721, Ownable {
    constructor() ERC721("METANFT", "MNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "http://dweb.lindensys.cn/ipns/k51qzi5uqu5divqrok0get110odatax0tv8uqh3forzp1zhoxy7ft7cua188gt/babaofan/";
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}