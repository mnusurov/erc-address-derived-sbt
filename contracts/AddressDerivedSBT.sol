// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {IERCXXXX} from "./interfaces/IERCXXXX.sol";
import {IERC721Metadata} from "./interfaces/IERC721Metadata.sol";

contract AddressDerivedSBT is IERCXXXX, IERC721Metadata {
    mapping(uint256 => bool) private _isMinted;

    string private _name;
    string private _symbol;
    string private _baseUri;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseUri_
    ) {
        _name = name_;
        _symbol = symbol_;
        _baseUri = baseUri_;
    }

    function mint(address to) external virtual returns (uint256 tokenId) {
        tokenId = deriveTokenId(to);

        require(!_isMinted[tokenId], AlreadyMinted());

        _isMinted[tokenId] = true;

        emit Transfer(address(0), to, tokenId);
    }

    function burn(uint256 tokenId) external virtual {
        address owner = ownerOf(tokenId);
        require(owner != address(0), NotMinted());

        require(msg.sender == owner, NotAuthorized());

        _isMinted[tokenId] = false;

        emit Transfer(owner, address(0), tokenId);
    }

    function balanceOf(address owner) external view virtual returns (uint256) {
        uint256 tokenId = deriveTokenId(owner);
        return _isMinted[tokenId] ? 1 : 0;
    }

    function name() external view virtual returns (string memory) {
        return _name;
    }

    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    function tokenURI(
        uint256 tokenId
    ) external view virtual returns (string memory) {
        require(ownerOf(tokenId) != address(0), NotMinted());
        return _baseUri;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        // Safe: tokenId derived from address (uint160 range guaranteed)
        // forge-lint: disable-next-line(unsafe-typecast)
        return _isMinted[tokenId] ? address(uint160(tokenId)) : address(0);
    }

    function deriveTokenId(
        address owner
    ) internal pure virtual returns (uint256) {
        return uint256(uint160(owner));
    }
}
