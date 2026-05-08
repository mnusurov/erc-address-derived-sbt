// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {IERC165} from "./IERC165.sol";
import {IERC5192} from "./IERC5192.sol";
import {IERC721Core} from "./IERC721Core.sol";
import {IERC721Metadata} from "./IERC721Metadata.sol";

/// @title ERC-XXXX Address-Derived Non-Transferable Token
/// @dev See https://eips.ethereum.org/EIPS/eip-XXXX
/// @dev Token ID is derived deterministically: uint256(uint160(owner)) ^ uint256(uint160(address(this)))
interface IERCXXXX is IERC165, IERC5192, IERC721Core, IERC721Metadata {
    /// @dev Thrown when attempting to mint to an address that already holds a token
    error AlreadyMinted();

    /// @dev Thrown when querying a token that has not been minted
    error NotMinted();

    /// @dev Thrown when caller is not the token owner
    error NotAuthorized();

    /// @notice Mint a token to the specified address
    /// @dev Reverts if token already minted. Token ID is derived deterministically, see tokenIdOf().
    ///      MUST emit Transfer(address(0), to, tokenId) and Locked(tokenId).
    /// @param to Address to receive the token
    /// @return tokenId The derived token ID
    function mint(address to) external returns (uint256 tokenId);

    /// @notice Burn the token with the given ID
    /// @dev Only the token owner MAY burn their token.
    ///      MUST revert if token not minted or caller is not the token owner.
    ///      MUST emit Transfer(owner, address(0), tokenId).
    /// @param tokenId ID of the token to burn
    function burn(uint256 tokenId) external;

    /// @notice Derive the token ID for a given owner address
    /// @dev Computed as: uint256(uint160(owner)) ^ uint256(uint160(address(this)))
    ///      Cross-contract isolation: same owner gets different tokenIds in different contracts.
    /// @param owner Address to derive token ID from
    /// @return tokenId The derived token ID
    function tokenIdOf(address owner) external view returns (uint256 tokenId);
}
