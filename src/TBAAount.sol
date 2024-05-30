// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./ERC6551Account.sol";

contract TBAAount is ERC6551Account, IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function safeTransfer(address fishpartAddress, address to, uint tokenId) public {
        require(msg.sender == owner() || msg.sender == getApproved(fishpartAddress, tokenId), "only owner and approved can approve");

        IERC721 fishpart = IERC721(fishpartAddress);
        fishpart.safeTransferFrom(address(this), to, tokenId);
    }

    function approve(address fishpartAddress, address to, uint tokenId) public {
        require(msg.sender == owner(), "only owner can approve");

        IERC721 fishpart = IERC721(fishpartAddress);
        fishpart.approve(to, tokenId);
    }

    function getApproved(address fishpartAddress, uint tokenId) public view returns (address operator) {
        IERC721 fishpart = IERC721(fishpartAddress);
        return fishpart.getApproved(tokenId);
    }   

}
