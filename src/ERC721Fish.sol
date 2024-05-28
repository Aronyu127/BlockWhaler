// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC6551Registry.sol";
import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC721FishParts.sol";
import "./ERC721FishParts.sol";
import "./ERC6551Registry.sol";
import "./ERC6551Account.sol";

contract ERC721Fish is ERC721, ERC721URIStorage, Ownable, ERC6551Registry {
    mapping(string => address) fishParts;
    uint256 private _nextTokenId;
    mapping(uint => uint) private _ratios;
    mapping(uint => address) private _tbaFishAddresses;
    address private _erc6551RegistryAddress;
    address private _erc6551AccountAddress;


    constructor(
        address initialOwner
    ) ERC721("Fish", "FishNFT") Ownable(initialOwner) {
        _erc6551RegistryAddress = address(new ERC6551Registry());
        _erc6551AccountAddress = address(new ERC6551Account());


        fishParts["Head"] = address(new ERC721FishParts(initialOwner, "Head", "head"));
        fishParts["Eye"] = address(new ERC721FishParts(initialOwner, "Eye", "eye"));
        fishParts["Tail"] = address(new ERC721FishParts(initialOwner, "Tail", "tail"));
        fishParts["Background"] = address(new ERC721FishParts(
            initialOwner,
            "Background",
            "background"
        ));

    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        address erc721FishAddress = address(this);
        IERC6551Registry _erc6551Registry = IERC6551Registry(_erc6551RegistryAddress);
        address tbaFishAddress = _erc6551Registry.createAccount(_erc6551AccountAddress, block.chainid, erc721FishAddress, tokenId, 0, abi.encodePacked(""));

        _setTBAFish(tokenId, tbaFishAddress);
        _setRatio(tokenId);
        // _safeMintFishParts(tokenId);
    }

    function _safeMintFishParts(uint _tokenId) internal {
        address _tbaFishAddress = _tbaFishAddresses[_tokenId];
        _safeMintFishPart("Head", _tbaFishAddress, "");
        _safeMintFishPart("Eye", _tbaFishAddress, "");
        _safeMintFishPart("Tail", _tbaFishAddress, "");
        _safeMintFishPart("Background", _tbaFishAddress, "");
    }

    function _safeMintFishPart(string memory _part, address _to, string memory _uri) internal {
        IERC721FishParts _fishParts = IERC721FishParts(fishParts[_part]);
        _fishParts.safeMint(_to, _uri);
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

    function ratio(uint _tokenId) public view returns (uint) {
        return _ratios[_tokenId];
    }

    function _setRatio(uint _tokenId) internal  {
        uint _ratio = block.number % 10000;
        _ratios[_tokenId] = _ratio;
    }

    function tbaFish(uint _tokenId) public view returns (address) {
        return _tbaFishAddresses[_tokenId];
    }

    function _setTBAFish(uint _tokenId, address tbaFishAddress) internal {
        _tbaFishAddresses[_tokenId] = tbaFishAddress;
    }

}
