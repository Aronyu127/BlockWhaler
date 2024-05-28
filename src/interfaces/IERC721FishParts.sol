// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721FishParts {
    function safeMint(address to, string memory uri) external;
}