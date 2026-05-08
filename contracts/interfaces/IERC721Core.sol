// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

/// @title Minimal ERC-721 Core Interface
/// @dev Provides the Transfer event and the two read functions shared with ERC-721.
///      IERCXXXX extends this interface to ensure Transfer event compatibility with
///      ERC-721 indexers and wallets without inheriting transfer functionality.
interface IERC721Core {
    /// @dev Emitted when a token is minted (from == address(0)) or burned (to == address(0))
    /// @param from Sender address (address(0) on mint)
    /// @param to Recipient address (address(0) on burn)
    /// @param tokenId Token identifier
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// @notice Get the token count for an address
    /// @dev Returns 0 or 1 — only one token per address is allowed by design
    /// @param owner Address to query
    /// @return Number of tokens owned (0 or 1)
    function balanceOf(address owner) external view returns (uint256);

    /// @notice Get the owner of a token
    /// @dev MUST revert if token not minted
    /// @param tokenId Token identifier
    /// @return Address that owns the token
    function ownerOf(uint256 tokenId) external view returns (address);
}
