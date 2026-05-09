---
erc: XXXX
title: Address-Derived Non-Transferable Token
description: A minimal soulbound token where tokenId is deterministically derived from the owner's address XOR'd with the contract address.
author: Marat Nusurov (@mnusurov)
discussions-to: https://ethereum-magicians.org/t/erc-idea-address-derived-non-transferable-token-soulbound-token/28475
status: Draft
type: Standards Track
category: ERC
created: 2026-05-07
requires: 165, 721
---

# ERC-XXXX: Address-Derived Non-Transferable Token

## Abstract

This standard proposes a minimal standard for non-transferable tokens (Soulbound tokens) where the `tokenId` is **deterministically derived** from the owner's address using XOR with the contract address: `tokenId = uint256(uint160(owner)) ^ uint160(address(this))`. This design enforces **one-token-per-address** at the protocol level, dramatically reduces storage costs, and makes the semantics of the token extremely clear.

## Motivation

Most Soulbound token implementations rely on extending ERC-721 with transfer restrictions (ERC-5192, ERC-5484) or introduce consensual transfer mechanisms (ERC-4973). These approaches suffer from:

1. **Storage overhead**: typical ERC-721-based SBTs inherit multiple unused state
   variables (`owners`, `balances`, `tokenApprovals`, `operatorApprovals`) and
   often a sequential counter that is not tied to the owner's identity. This
   standard replaces all of them with a single `mapping(uint256 => bool)` for
   existence tracking.
2. **Allow multiple tokens per address**: unless explicitly checked, the same
   address can receive several tokens, contradicting the one-to-one semantics
   expected from many credentials.

ERC-8129 improves this by removing transfer functions entirely, but still uses sequential token IDs and `mapping(uint256 => address)` storage.

This proposal solves these by making the `tokenId` itself represent the owner's address through deterministic derivation, enabling:
- Single `mapping(uint256 => bool)` for existence tracking
- Invertibility without storage for owner computation
- Hard-enforced one-per-address at tokenId level
- Cross-contract tokenId isolation via XOR with `address(this)`

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

### Core Interface (IERCXXXX)

Every compliant contract MUST implement the `IERCXXXX` interface:

The interface identifier for this standard is `0x5fc816fe`, computed per ERC-165 from all functions in IERCXXXX and its parent interfaces.

```solidity
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
    /// @dev Computed as: uint256(uint160(owner)) ^ uint160(address(this))
    ///      Cross-contract isolation: same owner gets different tokenIds in different contracts.
    /// @param owner Address to derive token ID from
    /// @return tokenId The derived token ID
    function tokenIdOf(address owner) external view returns (uint256 tokenId);
}
```

### Required Interfaces

Compliant contracts MUST implement the following interfaces:

**IERC721Core** — Minimal ERC-721 Core (Transfer event + balanceOf + ownerOf)
```solidity
interface IERC721Core {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}
```

**IERC165** — Standard Interface Detection
```solidity
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
```

**IERC5192** — Minimal Soulbound NFTs (Interface ID: 0xb45a3c0e)
```solidity
interface IERC5192 {
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);
    function locked(uint256 tokenId) external view returns (bool);
}
```

**IERC721Metadata** — ERC-721 Metadata Interface
```solidity
interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
```

### Behavior Specification

1. **Token ID Derivation**: `tokenIdOf(owner) = uint256(uint160(owner)) ^ uint160(address(this))`
   - XOR provides cross-contract isolation — same owner gets different tokenIds in different contracts
   - Owner can be computed from tokenId via inverse XOR: `owner = address(uint160(tokenId ^ uint160(address(this))))`
   - One-per-address is hard-enforced at tokenId level
   - For `owner = address(0)`, `tokenIdOf` returns `uint160(address(this))`, which is a valid tokenId (implicitly widened to uint256). Minting to `address(0)` is not prohibited by this standard.

2. **Minting**:
   - Tokens MUST be minted to a specified address via the `to` parameter
   - MUST revert if token already minted (one-per-address enforced)
   - MUST emit `Transfer(address(0), to, tokenId)` event
   - MUST emit `Locked(tokenId)` event (ERC-5192 compatibility)
   - Access control for `mint()` is intentionally left to the implementation

3. **Burning**:
   - Only token owner MUST be able to burn their token
   - MUST revert if token not minted or caller is not owner
   - MUST emit `Transfer(owner, address(0), tokenId)` event
   - Re-mint after burn is allowed

4. **Non-Transferability**:
   - Compliant contracts MUST NOT implement any transfer functionality
   - Tokens are permanently bound to the owner address

5. **Owner Queries**:
   - `ownerOf(tokenId)` — MUST return the address that owns the specified token
   - `ownerOf(tokenId)` — MUST revert if not minted
   - `balanceOf(owner)` — MUST return 1 if minted
   - `balanceOf(owner)` — MUST return 0 if NOT minted
   - `tokenIdOf(owner)` — public view function for dapps to compute tokenId

6. **Locking (ERC-5192)**:
   - `locked(tokenId)` — MUST return `true` for any minted token
   - `locked(tokenId)` — MUST revert if token not minted
   - All tokens are permanently locked — there is no mechanism to unlock
   - The `Unlocked` event defined in `IERC5192` MUST NOT be emitted — burning destroys the token, not unlocks it

7. **Interface Detection (ERC-165)**:
   - `supportsInterface` MUST return `true` for `IERCXXXX` (`0x5fc816fe`), `IERC5192` (`0xb45a3c0e`), `IERC721Metadata` (`0x5b5e139f`), and `IERC165` (`0x01ffc9a7`) interface IDs

8. **Total Supply (Optional)**:
   - `totalSupply() external view returns (uint256)` — OPTIONAL
   - If implemented, MUST return the number of currently minted (non-burned) tokens


## Rationale

### Why Deterministic Token ID?

Traditional NFT standards use sequential counters. For non-transferable tokens where one-per-address is desired, this is inefficient:

- **Storage**: Sequential IDs require `mapping(uint256 => address)` to track ownership
- **Multiple mints**: Must explicitly check if address already has a token
- **No identity linkage**: Token ID has no relationship to the owner

Address-derived token IDs solve this:
- **Minimal storage**: `mapping(uint256 => bool)` for existence only
- **Hard-enforced uniqueness**: Same address always gets same tokenId
- **Identity-bound**: TokenId inherently represents the owner

### Why XOR with address(this)?

The XOR operation provides:
- **Cross-contract isolation**: Same owner gets different tokenIds in different contracts
- **Invertibility without storage**: Owner can be computed from tokenId
- **Collision-free**: XOR with `address(this)` is a bijection on `uint160` — two distinct owner addresses can never produce the same `tokenId` within a single contract
- **Gas efficiency**: Cheaper than keccak256 hash

### Why mint() is in the Core Interface?

Like ERC-8129, this standard defines `mint(address to)` as part of the core interface. The standard does not mandate access control — implementations choose their own minting policy:
- Issuer-controlled: override `mint()` with an access control check
- Self-issuance: override `mint()` with `require(to == msg.sender)` to restrict minting to self
- Signature-based: override `mint()` to verify an off-chain signature

This flexibility reflects real-world use cases where credential issuance models vary.

### Why tokenIdOf() Function?

`tokenIdOf(address)` provides a bijective pair to `ownerOf(uint256)`:
- Dapps can compute tokenId without duplicating derivation logic
- Symmetry with `ownerOf` makes the interface intuitive
- Enables off-chain computation of tokenId for a given owner

### Why tokenURI Returns a Single Base URI?

`tokenURI(uint256)` returns the same base URI regardless of `tokenId`. This is intentional — the standard is minimal, and per-token differentiation is an application concern, not a protocol concern. Implementations that require per-token metadata (e.g., based on owner attributes or achievement level) MAY override `tokenURI()` with custom logic; they MUST still revert for unminted tokens and remain compatible with the core interface.

### Comparison with ERC-4973

ERC-4973 also uses a derived token ID — the EIP-712 hash of a bilateral agreement. This is a different form of derivation: the ID encodes the *content of consent* between issuer and receiver, not the receiver's identity. ERC-4973 still requires `mapping(uint256 => address)` for ownership and does not enforce one-per-address. Its design is optimized for consensual credential issuance where both parties sign; this standard is optimized for issuer-driven credential issuance where the receiver's identity itself is the token ID.

### Comparison with Existing Standards

| Feature | ERC-5192 / ERC-5484 | ERC-4973 | ERC-8129 | This Standard |
|---------|---------------------|----------|----------|---------------|
| Token ID | Sequential counter | Hash(EIP-712 agreement) | Sequential counter | Deterministic (address-derived) |
| Storage | `mapping(uint256 => address)` | `mapping(uint256 => address)` | `mapping(uint256 => address)` | `mapping(uint256 => bool)` |
| One-per-address | Explicit check | Not enforced | Not enforced | Hard-enforced at tokenId |
| ownerOf storage | Required | Required | Required | Computed (zero storage) |
| Minting | Restricted (usually) | Bilateral consent (EIP-712) | Issuer-only | Implementation-defined |
| Transfer functions | Present but blocked | Absent | Absent | Absent |
| ERC-165 | Yes | Yes | Yes | Yes |
| ERC-5192 | Native / No | No | No | Interface-compatible |
| Gas (mint/burn) | ~50k+ / ~45k+ | ~55k+ / ~50k+ | ~45k / ~40k | 33k / 8k |

## Backwards Compatibility

This standard is not backwards compatible with ERC-721. This is intentional — tokens are fundamentally non-transferable and use a different token ID mechanism.

Wallets and indexers can detect this standard via:
- ERC-165 `supportsInterface` with the `IERCXXXX` interface ID
- ERC-5192 `supportsInterface(0xb45a3c0e)` — identifies it as a soulbound token
- `Transfer` events (mint from `address(0)`, burn to `address(0)`)
- `tokenIdOf()` function presence

### Relationship to ERC-5192

This standard is not an extension of ERC-5192. ERC-5192 is itself an extension of ERC-721, and this standard does not extend ERC-721. However, this standard defines a `locked()` function and `Locked` event that are interface-compatible with ERC-5192 (interface ID `0xb45a3c0e`). Wallets and tooling that detect soulbound status via `supportsInterface(0xb45a3c0e)` will correctly identify compliant contracts as soulbound even though the underlying token model differs from ERC-721. For this reason, ERC-5192 is not listed in the `requires` field — the dependency is on interface compatibility, not inheritance.

## Reference Implementation

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.26;

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

    function supportsInterface(bytes4 interfaceId) external pure virtual returns (bool) {
        return interfaceId == 0x5fc816fe // IERCXXXX
            || interfaceId == 0x01ffc9a7 // IERC165
            || interfaceId == 0xb45a3c0e // IERC5192
            || interfaceId == 0x5b5e139f; // IERC721Metadata
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        require(_isMinted[tokenId], NotMinted());
        return address(uint160(tokenId ^ uint160(address(this))));
    }

    function tokenIdOf(address owner) public view virtual returns (uint256) {
        return uint256(uint160(owner)) ^ uint160(address(this));
    }

    function _mint(address to) internal virtual returns (uint256 tokenId) {
        tokenId = tokenIdOf(to);
        require(!_isMinted[tokenId], AlreadyMinted());
        _isMinted[tokenId] = true;
        emit Transfer(address(0), to, tokenId);
        emit Locked(tokenId);
    }
}
```

## Security Considerations

### Token ID Derivation

The XOR operation is bijective and reversible. Anyone can compute `tokenIdOf(address)` for any address, and `ownerOf(tokenId)` for any tokenId. This is by design — tokenIds are not secret.

### Token ID Privacy

`tokenIdOf(address)` is a deterministic public function. Anyone can compute the token ID for any address and query minting status without the token holder's participation. Token holdings are fully observable for any address by design, consistent with the public nature of the Ethereum blockchain.

Applications requiring privacy for credential status should use ZK-based approaches — for example, off-chain proofs against on-chain commitments — rather than this standard directly.

### Smart Contract Wallets

This standard is compatible with smart contract wallets (Safe multisigs, ERC-4337 account abstractions) since the token ID is derived from the deployer address regardless of key type. However, because the token is permanently bound to the address, key rotation through migration to a new address — a common recovery pattern for smart wallets — does not transfer the token. Users migrating to a new wallet address lose their bound token and must be reissued.

For ERC-4337 accounts: if a contract account is destroyed via `selfdestruct` and redeployed to the same CREATE2 address with different logic, the `tokenIdOf` result remains unchanged but the controlling logic has changed. Applications using this standard with upgradeable smart wallet accounts should account for this scenario.

### Minting Access Control

The standard does not enforce access control on `mint()`. The reference implementation exposes `mint()` as `external virtual`, allowing deployers to override it with their own policy (role-based, signature-based, etc.). Deployers SHOULD add access control appropriate to their use case.

**Unsolicited minting**: Because `mint(address to)` may be callable by anyone in a permissive deployment, a party could mint unwanted tokens to arbitrary addresses. While the one-per-address guarantee prevents repeated spam minting, deployers issuing credentials with meaningful semantics (KYC, membership, attestations) MUST restrict access to `mint()`. This concern was also raised in the ERC-8129 community discussion; responsibility is intentionally left to deployers rather than mandated by the standard.

### Re-mint After Burn

Burning a token allows re-minting to the same address. This enables credential reissuance after revocation. Applications requiring permanent revocation should implement additional logic.

### Private Key Compromise

If a user's private key is compromised, the attacker gains access to the non-transferable token. Unlike transferable tokens, recovery by moving to a secure address is impossible. Consider multi-signature schemes for high-value credentials.

### Minting to address(0)

`tokenIdOf(address(0))` returns a valid, non-zero tokenId (`= uint160(address(this))`). If a token is minted to `address(0)`, no one can ever burn it — `msg.sender` can never equal `address(0)`. This creates a permanently occupied slot. Implementations SHOULD add `require(to != address(0))` in `mint()` if this is undesirable.

### Permanent Binding

Tokens are permanently bound to their derived tokenId. If the address becomes inaccessible (lost keys, contract bugs), the token cannot be recovered.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
