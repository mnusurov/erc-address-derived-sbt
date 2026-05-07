// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

/// @title ERC-721 Metadata Interface (from EIP-721)
/// @dev This is a REQUIRED part of the standard
interface IERC721Metadata {
    /// @notice A descriptive name for the token collection
    function name() external view returns (string memory);

    /// @notice An abbreviated name for the token collection
    function symbol() external view returns (string memory);

    /// @notice A URI pointing to metadata for a specific token
    /// @dev Reverts if token not minted (checked via ownerOf)
    /// @param tokenId The identifier of the token
    /// @return The base URI string (same for all tokens)
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
