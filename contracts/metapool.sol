// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract metapool is IERC1155Receiver {
    event DoneStake(address from, uint256 tokenType);

    function supportsInterface(bytes4) external pure override returns (bool) {
      return true;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function stake_1155(IERC1155 token1155, uint256 id, uint256 amount)
        public
    {
        token1155.safeTransferFrom(msg.sender, address(this), id, amount, "");
        emit DoneStake(msg.sender, 0);  
    }

    function stake_721(IERC721 token721, uint256 id)
        public
    {
        token721.safeTransferFrom(msg.sender, address(this), id);
        emit DoneStake(msg.sender, 1);  
    }

    function stake_20(IERC20 token20, uint256 amount)
        public
    {
        token20.transferFrom(msg.sender, address(this), amount);
        emit DoneStake(msg.sender, 2); 
    }

}
