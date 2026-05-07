// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

interface IERCXXXX {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    error AlreadyMinted();
    error NotMinted();
    error NotAuthorized();

    function mint(address to) external returns (uint256 tokenId);
    function burn(uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
    function tokenIdOf(address owner) external view returns (uint256 tokenId);
    function balanceOf(address owner) external view returns (uint256);
}
