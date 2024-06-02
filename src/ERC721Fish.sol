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
import "./TBAAount.sol";


contract ERC721Fish is ERC721, ERC721URIStorage, Ownable {
    mapping(string => address) public fishParts;
    uint256 private _nextTokenId;
    mapping(uint => uint) private _ratios;
    mapping(uint => address) private _tbaFishAddresses;
    address private _erc6551RegistryAddress;
    address private _erc6551AccountAddress;


    constructor(
        address initialOwner
    ) ERC721("Fish", "FishNFT") Ownable(initialOwner) {
        _erc6551RegistryAddress = address(new ERC6551Registry());
        _erc6551AccountAddress = address(new TBAAount());


        address erc721FishAddr = address(this);
        fishParts["Head"] = address(new ERC721FishParts(erc721FishAddr, "Head", "head"));
        fishParts["Eye"] = address(new ERC721FishParts(erc721FishAddr, "Eye", "eye"));
        fishParts["Tail"] = address(new ERC721FishParts(erc721FishAddr, "Tail", "tail"));
        fishParts["Background"] = address(new ERC721FishParts(
            erc721FishAddr,
            "Background",
            "background"
        ));

    }

    // function safeMint(address _to, string memory _uri) public onlyOwner {
    function safeMint(address _to, string memory _uri) public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(_to, tokenId);
        // _setTokenURI(tokenId, _uri);
        _setTokenURI(tokenId, "ipfs://bafybeieoqze526y5vhz3nfdubrs77cp76y6fva7p54bic2qbajf4rtos7i/body.json");

        address erc721FishAddress = address(this);
        IERC6551Registry _erc6551Registry = IERC6551Registry(_erc6551RegistryAddress);
        address tbaFishAddress = _erc6551Registry.createAccount(_erc6551AccountAddress, block.chainid, erc721FishAddress, tokenId, 0, abi.encodePacked(""));

        _setTBAFish(tokenId, tbaFishAddress);
        _setRatio(tokenId);
        _safeMintFishParts(tokenId);
    }

    function _safeMintFishParts(uint _tokenId) internal {
        address _tbaFishAddress = _tbaFishAddresses[_tokenId];

        _safeMintFishPart("Head", _tbaFishAddress, "ipfs://bafybeieoqze526y5vhz3nfdubrs77cp76y6fva7p54bic2qbajf4rtos7i/head-chefhat.json");
        _safeMintFishPart("Eye", _tbaFishAddress, "ipfs://bafybeieoqze526y5vhz3nfdubrs77cp76y6fva7p54bic2qbajf4rtos7i/eye-normal%20copy.json");
        _safeMintFishPart("Tail", _tbaFishAddress, "ipfs://bafybeieoqze526y5vhz3nfdubrs77cp76y6fva7p54bic2qbajf4rtos7i/tail-llifebuoy.json");
        _safeMintFishPart("Background", _tbaFishAddress, "ipfs://bafybeieoqze526y5vhz3nfdubrs77cp76y6fva7p54bic2qbajf4rtos7i/bg-001.json");
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
