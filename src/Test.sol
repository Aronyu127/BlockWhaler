// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";


import "./ERC721Fish.sol";
import "./interfaces/IERC721Fish.sol";

contract Test is Ownable {
    address fishAddress;

    // constructor(address initOwnAddress) ERC721Fish(initOwnAddress) {}
    constructor() Ownable(msg.sender) {}

    function setFishAddress(address addr) public onlyOwner {
        fishAddress = addr;
    }

    function safeMint(address to, string memory tokenURL) public onlyOwner {
        IERC721Fish erc721Fish = IERC721Fish(fishAddress);
        erc721Fish.safeMint(to, tokenURL);
    }

}
