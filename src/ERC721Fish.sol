// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC721FishParts.sol";
import "./ERC6551Registry.sol";

contract ERC721Fish is ERC721, ERC721URIStorage, Ownable {
    mapping(string => ERC721FishParts) fishParts;
    uint256 private _nextTokenId;
    address public ERC6551RegistryAddr;

    constructor(
        address initialOwner
    ) ERC721("Fish", "FishNFT") Ownable(initialOwner) {
        ERC6551RegistryAddr = address(new ERC6551Registry());

        fishParts["Head"] = new ERC721FishParts(initialOwner, "Head", "head");
        fishParts["Eye"] = new ERC721FishParts(initialOwner, "Eye", "eye");
        fishParts["Tail"] = new ERC721FishParts(initialOwner, "Tail", "tail");
        fishParts["Background"] = new ERC721FishParts(
            initialOwner,
            "Background",
            "background"
        );
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
