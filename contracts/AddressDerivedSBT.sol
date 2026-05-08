// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {IERCXXXX} from "./interfaces/IERCXXXX.sol";

contract AddressDerivedSBT is IERCXXXX {
    mapping(uint256 => bool) private _isMinted;

    string private _name;
    string private _symbol;
    string private _baseUri;

    constructor(string memory name_, string memory symbol_, string memory baseUri_) {
        _name = name_;
        _symbol = symbol_;
        _baseUri = baseUri_;
    }

    function mint(address to) external virtual returns (uint256 tokenId) {
        return _mint(to);
    }

    function burn(uint256 tokenId) external virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, NotAuthorized());

        delete _isMinted[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function supportsInterface(bytes4 interfaceId) external pure virtual returns (bool) {
        return interfaceId == 0x5fc816fe // IERCXXXX
            || interfaceId == 0xb45a3c0e // IERC5192
            || interfaceId == 0x5b5e139f // IERC721Metadata
            || interfaceId == 0x01ffc9a7; // IERC165
    }

    function balanceOf(address owner) external view virtual returns (uint256) {
        return _isMinted[tokenIdOf(owner)] ? 1 : 0;
    }

    function locked(uint256 tokenId) external view virtual returns (bool) {
        require(_isMinted[tokenId], NotMinted());
        return true;
    }

    function name() external view virtual returns (string memory) {
        return _name;
    }

    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view virtual returns (string memory) {
        require(_isMinted[tokenId], NotMinted());
        return _baseUri;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        require(_isMinted[tokenId], NotMinted());
        return address(uint160(tokenId ^ uint256(uint160(address(this))))); // forge-lint: disable-line(unsafe-typecast)
    }

    function tokenIdOf(address owner) public view virtual returns (uint256) {
        return uint256(uint160(owner)) ^ uint256(uint160(address(this)));
    }

    function _mint(address to) internal virtual returns (uint256 tokenId) {
        tokenId = tokenIdOf(to);
        require(!_isMinted[tokenId], AlreadyMinted());
        _isMinted[tokenId] = true;
        emit Transfer(address(0), to, tokenId);
        emit Locked(tokenId);
    }
}
