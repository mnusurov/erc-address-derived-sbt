// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

/// @title ERC-XXXX Address-Derived Non-Transferable Token
/// @dev See https://eips.ethereum.org/EIPS/eip-XXXX
/// @dev Token ID is derived deterministically, see tokenIdOf()
interface IERCXXXX {
    /// @dev Emitted when a token is minted (from address(0)) or burned (to address(0))
    /// @param from Sender address (address(0) on mint)
    /// @param to Recipient address (address(0) on burn)
    /// @param tokenId Token ID, see tokenIdOf()
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// @dev Thrown when attempting to mint to an address that already holds a token
    error AlreadyMinted();

    /// @dev Thrown when querying a token that has not been minted
    error NotMinted();

    /// @dev Thrown when caller is not the token owner
    error NotAuthorized();

    /// @notice Mint a token to the specified address
    /// @dev Reverts if token already minted. Token ID is derived deterministically, see tokenIdOf().
    /// @param to Address to receive the token
    /// @return tokenId The derived token ID
    function mint(address to) external returns (uint256 tokenId);

    /// @notice Burn the token with the given ID
    /// @dev Reverts if token not minted or if caller is not the token owner
    /// @param tokenId ID of the token to burn
    function burn(uint256 tokenId) external;

    /// @notice Get the owner of a token by token ID
    /// @dev Returns address(0) if token not minted (does NOT revert)
    /// @param tokenId ID of the token to query
    /// @return owner The address that owns the token, or address(0) if not minted
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /// @notice Derive the token ID for a given owner address
    /// @dev Computed as: uint256(uint160(owner)) ^ uint256(uint160(address(this)))
    ///      This provides cross-contract tokenId isolation - same owner gets different tokenIds in different contracts
    /// @param owner Address to derive token ID from
    /// @return tokenId The derived token ID
    function tokenIdOf(address owner) external view returns (uint256 tokenId);

    /// @notice Get the token count for an address
    /// @dev Always returns 0 or 1 - only one token per address is allowed by design
    /// @param owner Address to query balance for
    /// @return Number of tokens owned (0 or 1)
    function balanceOf(address owner) external view returns (uint256);
}
