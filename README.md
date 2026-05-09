# ERC-XXXX: Address-Derived Non-Transferable Token

**Deterministic Address-Bound Soulbound Token Standard**

> Ultra-minimal, gas-efficient, storage-optimized non-transferable token where `tokenId` is deterministically derived from the owner's address — see [EIP-XXXX.md](./EIP-XXXX.md) for the full specification.

[![License: CC0-1.0](https://img.shields.io/badge/License-CC0_1.0-lightgrey)](LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.35-363636?logo=solidity)](https://github.com/ethereum/solidity)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-000000?logo=ethereum)](https://book.getfoundry.sh/)
[![EIP](https://img.shields.io/badge/EIP-Draft-blueviolet)](./EIP-XXXX.md)

---

## Abstract

This proposal introduces a new Ethereum standard for **Soulbound Tokens (SBTs)** where the `tokenId` is deterministically derived from the owner's address. It enforces **one-token-per-address** at the protocol level, dramatically reduces storage costs, and makes the semantics of the token extremely clear. **Inspired by** **[ERC-8129: Non-Transferable Token](https://ethereum-magicians.org/t/erc-8129-non-transferable-token/27407)**'s approach of a dedicated non-transferable standard, this proposal replaces sequential token IDs with address-derived deterministic token IDs for stronger guarantees and lower storage.

---

## Key Features

- **Deterministic Token ID** — derived from the owner's address (see [`tokenIdOf()`](./EIP-XXXX.md) in the specification)
- **Strict one-per-address** enforced at the token ID level
- **Minimal storage** — single `mapping(uint256 => bool)` for existence tracking
- **No approvals, no transfers, no operators** — true non-transferable
- **ERC-5192 and ERC-165 compatible** — wallet and indexer support out of the box

---

## Gas Efficiency

| Operation | Gas Cost |
|-----------|----------|
| TokenIdOf | 7,417 |
| Mint | 32,905 |
| OwnerOf (minted) | 10,389 |
| BalanceOf (minted) | 9,618 |
| Burn | 8,006 |

*Gas measured with vm.startSnapshotGas in test/Gas.t.sol.*

---

→ **Full specification:** [EIP-XXXX.md](./EIP-XXXX.md)
