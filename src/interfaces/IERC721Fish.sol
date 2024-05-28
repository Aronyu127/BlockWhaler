// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

interface IERC721Fish is IERC721 {

    function safeMint(address _to, string memory _uri) external;

    function tbaFish(uint _tokenId) external returns (address); 

    function ratio(uint _tokenId) external returns (uint ratio);
}