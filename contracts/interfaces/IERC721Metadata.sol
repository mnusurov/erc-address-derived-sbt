// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

/// @title ERC-721 Metadata Interface (from EIP-721)
/// @dev This is a REQUIRED part of the standard
interface IERC721Metadata {
    /// @notice A descriptive name for the token collection
    function name() external view returns (string memory);

    /// @notice An abbreviated name for the token collection
    function symbol() external view returns (string memory);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given token
    /// @dev Throws if `tokenId` is not a valid (minted) token. URIs are defined in RFC 3986.
    /// @param tokenId The identifier of the token
    /// @return The URI string for the token
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
