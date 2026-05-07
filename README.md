# ERC-XXXX: Address-Derived Non-Transferable Token

**Deterministic Address-Bound Soulbound Token Standard**

> Ultra-minimal, gas-efficient, storage-optimized non-transferable token where `tokenId` is deterministically derived from the owner's address.

---

## Abstract

This proposal introduces a new Ethereum standard for **Soulbound Tokens (SBTs)** / non-transferable tokens, where the `tokenId` is not a sequential counter, but a **deterministic function of the recipient's address** (`uint256(uint160(owner))`).

This design enforces **one-token-per-address** at the protocol level, dramatically reduces storage costs, simplifies `ownerOf` and `balanceOf`, and makes the semantics of the token extremely clear.

It builds upon and extends the ideas from **[ERC-8129: Non-Transferable Token](https://ethereum-magicians.org/t/erc-8129-non-transferable-token/27407)**.

---

## Motivation

Most Soulbound tokens (diplomas, memberships, attestations, achievements, KYC credentials, etc.) have the following natural properties:

- One token per address per type
- Cannot be transferred
- Issued by a trusted authority (issuer)
- Should be extremely cheap to verify

Existing standards (ERC-721 + ERC-5192/5484, ERC-4973, ERC-8129) either:
- Waste storage on mappings,
- Allow accidental multiple mints to the same address,
- Or require unnecessary complexity.

**Address-Derived design** solves these problems elegantly by making the `tokenId` itself carry the identity of the owner.

---

## Key Features

- **Deterministic Token ID**: `tokenId = uint256(uint160(owner)) ^ uint256(uint160(address(this)))`
- **Strict one-per-address** enforced at the token ID level
- **Simple mapping storage**: existence tracking via a single `mapping(uint256 => bool)`
- **Gas-efficient** `ownerOf` and `balanceOf`
- **No approvals, no transfers, no operators** (true non-transferable)
- **Permissionless minting** — anyone can mint a token to any address (one per address enforced at tokenId level)
- **Transfer events** on mint/burn for indexer compatibility (Etherscan, The Graph)
- **Name, Symbol, and Base URI** set at construction time, all functions virtual for extensibility
- Extremely simple and auditable contract (~70 LOC)

---

## How It Works

```solidity
// Deploy
AddressDerivedSBT sbt = new AddressDerivedSBT("Name", "SYM", "https://base.uri/");

// Minting (permissionless — anyone can mint to any address)
sbt.mint(studentAddress);        // tokenId is automatically derived

// Querying
address owner = sbt.ownerOf(tokenId);     // reverts if not minted
uint256 balance = sbt.balanceOf(user);

// Metadata
string name = sbt.name();
string symbol = sbt.symbol();
string uri = sbt.tokenURI(tokenId);       // returns base URI if token exists, reverts if not minted

// Burning
sbt.burn(tokenId);                        // by owner only
```

## Interface

### IERCXXXX (Core)

```solidity
interface IERCXXXX {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function mint(address to) external returns (uint256 tokenId);
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address owner) external view returns (uint256);
}
```

### IERC721Metadata (Optional, for metadata)

```solidity
interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
```

The reference implementation implements both interfaces (`AddressDerivedSBT is IERCXXXX, IERC721Metadata`).

## Gas Efficiency

| Operation | Gas Cost (approx) |
|-----------|------------------|
| Mint      | 32,092         |
| Burn      | 26,438         |
| ownerOf   | revert (unminted) / 34,145 (minted) |
| balanceOf | 10,005 (unminted) / 33,295 (minted) |

The reference implementation uses a simple `mapping(uint256 => bool)` for existence tracking, keeping the contract minimal, auditable, and gas-efficient for the one-per-address use case. Minting is permissionless — any address can mint a token to any recipient.

---

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/) (v1.5.0+ recommended)
- Solidity `v0.8.35`

### Quick Start

```bash
# Build contracts
forge build

# Run tests
forge test

# Gas report (snapshot)
forge snapshot

# Format code
forge fmt
```

### Project Structure

```
contracts/         # Solidity source code
├── AddressDerivedSBT.sol    # Reference implementation
└── interfaces/
    ├── IERCXXXX.sol         # Core standard interface
    └── IERC721Metadata.sol  # Metadata interface (ERC-721 compatible)

test/              # Foundry tests
├── AddressDerivedSBT.t.sol

lib/               # Dependencies (forge-std)
```