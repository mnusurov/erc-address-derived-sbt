# ERC-XXXX: Address-Derived Non-Transferable Token

**Deterministic Address-Bound Soulbound Token Standard**

> Ultra-minimal, gas-efficient, storage-optimized non-transferable token where `tokenId` is deterministically derived from the owner's address — see [EIP-XXXX.md](./EIP-XXXX.md) for the full specification.

---

## Abstract

This proposal introduces a new Ethereum standard for **Soulbound Tokens (SBTs)** where the `tokenId` is deterministically derived from the owner's address. It enforces **one-token-per-address** at the protocol level, dramatically reduces storage costs, and makes the semantics of the token extremely clear. It builds upon and extends **[ERC-8129: Non-Transferable Token](https://ethereum-magicians.org/t/erc-8129-non-transferable-token/27407)**.

---

## Key Features

- **Deterministic Token ID** — derived from the owner's address (see [`tokenIdOf()`](./EIP-XXXX.md) in the specification)
- **Strict one-per-address** enforced at the token ID level
- **Minimal storage** — single `mapping(uint256 => bool)` for existence tracking
- **No approvals, no transfers, no operators** — true non-transferable
- **ERC-5192 and ERC-165 compatible** — wallet and indexer support out of the box

---

## Gas Efficiency

| Operation | Gas Cost (approx) |
|-----------|------------------|
| Mint      | 32,092           |
| Burn      | 26,491           |
| ownerOf   | revert (unminted) / 34,176 (minted) |
| balanceOf | 10,027 (unminted) / 33,317 (minted) |

---

→ **Full specification:** [EIP-XXXX.md](./EIP-XXXX.md)
