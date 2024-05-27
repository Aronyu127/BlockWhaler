// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC721FishParts.sol";
import "./ERC6551Registry.sol";
import "./ERC6551Account.sol";

contract ERC721Fish is ERC721, ERC721URIStorage, Ownable, ERC6551Registry {
    mapping(string => ERC721FishParts) fishParts;
    uint256 private _nextTokenId;
    ERC6551Registry public erc6551Registry;
    ERC6551Account public erc6551Account;

    constructor(
        address initialOwner
    ) ERC721("Fish", "FishNFT") Ownable(initialOwner) {
        erc6551Registry = new ERC6551Registry();
        erc6551Account = new ERC6551Account();

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

        erc6551Registry.createAccount(address(erc6551Account), 1, address(this), tokenId, 0, abi.encodePacked(
            "NFT Name:",
            "My Awesome NFT",
            "Description:",
            "A unique and valuable digital collectible.",
            "Attributes:",
            "IPFS Hash:",
            "Qmhash/for/my/nft/metadata.json"
        ));
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
