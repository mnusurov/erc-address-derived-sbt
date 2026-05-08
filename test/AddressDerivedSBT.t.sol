// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {Test, Vm} from "forge-std/Test.sol";

import {AddressDerivedSBT} from "../contracts/AddressDerivedSBT.sol";
import {IERC165, IERC5192, IERC721Core, IERC721Metadata, IERCXXXX} from "../contracts/interfaces/IERCXXXX.sol";

contract AddressDerivedSBTTest is Test {
    AddressDerivedSBT public sbt;
    address public alice = address(0x5678);
    address public bob = address(0x9ABC);

    string public constant TOKEN_NAME = "Address-Derived SBT";
    string public constant TOKEN_SYMBOL = "ADSBT";
    string public constant BASE_URI = "https://example.com/metadata/";

    function setUp() public {
        sbt = new AddressDerivedSBT(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);
    }

    // ─── Mint ───────────────────────────────────────────────────

    function test_Mint_Success() public {
        uint256 tokenId = sbt.mint(alice);

        uint256 expectedTokenId = sbt.tokenIdOf(alice);
        assertEq(tokenId, expectedTokenId);
        assertEq(sbt.ownerOf(tokenId), alice);
        assertEq(sbt.balanceOf(alice), 1);
    }

    function test_Mint_RevertWhen_AlreadyMinted() public {
        sbt.mint(alice);

        vm.expectRevert(IERCXXXX.AlreadyMinted.selector);
        sbt.mint(alice);
    }

    function test_Mint_EmitsTransferEvent() public {
        uint256 expectedTokenId = sbt.tokenIdOf(alice);

        vm.expectEmit(true, true, true, true);
        emit IERC721Core.Transfer(address(0), alice, expectedTokenId);
        sbt.mint(alice);
    }

    function test_Mint_AllowsMintToZeroAddress() public {
        uint256 tid = sbt.mint(address(0));

        uint256 expectedTid = sbt.tokenIdOf(address(0));
        assertEq(tid, expectedTid);
        assertEq(sbt.ownerOf(tid), address(0));
        assertEq(sbt.balanceOf(address(0)), 1);
    }

    function test_Mint_AllowsAnyAddressToMintForAlice() public {
        vm.prank(bob);
        uint256 tokenId = sbt.mint(alice);

        assertEq(sbt.ownerOf(tokenId), alice);
    }

    // ─── Burn ───────────────────────────────────────────────────

    function test_Burn_ByOwner() public {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.balanceOf(alice), 1);

        vm.prank(alice);
        sbt.burn(tokenId);

        assertEq(sbt.balanceOf(alice), 0);
    }

    function test_Burn_RevertWhen_NotOwner() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(bob);
        vm.expectRevert(IERCXXXX.NotAuthorized.selector);
        sbt.burn(tokenId);
    }

    function test_Burn_RevertWhen_NotMinted() public {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.burn(tid);
    }

    function test_Burn_EmitsTransferEvent() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit IERC721Core.Transfer(alice, address(0), tokenId);
        sbt.burn(tokenId);
    }

    function test_Burn_AllowsReMint() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        sbt.mint(alice);

        assertEq(sbt.balanceOf(alice), 1);
    }

    // ─── ownerOf ────────────────────────────────────────────────

    function test_OwnerOf_RevertWhenNotMinted() public {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.ownerOf(tid);
    }

    function test_OwnerOf_ReturnsOwnerWhenMinted() public {
        sbt.mint(alice);
        assertEq(sbt.ownerOf(sbt.tokenIdOf(alice)), alice);
    }

    function test_OwnerOf_RevertAfterBurn() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.ownerOf(tokenId);
    }

    // ─── balanceOf ──────────────────────────────────────────────

    function test_BalanceOf_ReturnsZeroForUnmintedAddress() public view {
        assertEq(sbt.balanceOf(bob), 0);
    }

    function test_BalanceOf_ReturnsOneForMintedAddress() public {
        sbt.mint(alice);
        assertEq(sbt.balanceOf(alice), 1);
    }

    function test_BalanceOf_ReturnsZeroForZeroAddress() public view {
        assertEq(sbt.balanceOf(address(0)), 0);
    }

    function test_BalanceOf_ReturnsZeroAfterBurn() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        assertEq(sbt.balanceOf(alice), 0);
    }

    // ─── Metadata ───────────────────────────────────────────────

    function test_Name() public view {
        assertEq(sbt.name(), TOKEN_NAME);
    }

    function test_Symbol() public view {
        assertEq(sbt.symbol(), TOKEN_SYMBOL);
    }

    function test_TokenURI_RevertWhenNotMinted() public {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.tokenURI(tid);
    }

    function test_TokenURI_ReturnsBaseURI() public {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.tokenURI(tokenId), BASE_URI);
    }

    function test_TokenURI_ReturnsBaseURIAfterReMint() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        sbt.mint(alice);

        assertEq(sbt.tokenURI(tokenId), BASE_URI);
    }

    // ─── tokenIdOf ─────────────────────────────────────────────

    function test_TokenIdOf_ReturnsDeterministicValue() public view {
        uint256 tid = sbt.tokenIdOf(alice);
        uint256 expected = uint256(uint160(alice)) ^ uint256(uint160(address(sbt)));
        assertEq(tid, expected);
    }

    function test_TokenIdOf_ZeroAddress() public view {
        uint256 tid = sbt.tokenIdOf(address(0));
        uint256 expected = 0 ^ uint256(uint160(address(sbt)));
        assertEq(tid, expected);
    }

    function test_TokenIdOf_RoundTrip() public {
        address owner = alice;
        uint256 tid = sbt.tokenIdOf(owner);
        assertEq(sbt.balanceOf(owner), 0);
        sbt.mint(owner);
        assertEq(sbt.balanceOf(owner), 1);
        assertEq(sbt.ownerOf(tid), owner);
    }

    function test_TokenIdOf_ConsistentAcrossCalls() public view {
        assertEq(sbt.tokenIdOf(alice), sbt.tokenIdOf(alice));
    }

    // ─── supportsInterface ──────────────────────────────────────

    function test_SupportsInterface_IERC165() public view {
        assertEq(sbt.supportsInterface(type(IERC165).interfaceId), true);
    }

    function test_SupportsInterface_IERCXXXX() public view {
        assertEq(sbt.supportsInterface(type(IERCXXXX).interfaceId), true);
    }

    function test_SupportsInterface_IERC5192() public view {
        assertEq(sbt.supportsInterface(type(IERC5192).interfaceId), true);
    }

    function test_SupportsInterface_IERC721Metadata() public view {
        assertEq(sbt.supportsInterface(type(IERC721Metadata).interfaceId), true);
    }

    function test_SupportsInterface_ReturnsFalseForUnknown() public view {
        assertEq(sbt.supportsInterface(0xdeadbeef), false);
    }

    // ─── locked ─────────────────────────────────────────────────

    function test_Locked_ReturnsTrueWhenMinted() public {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.locked(tokenId), true);
    }

    function test_Locked_RevertsWhenNotMinted() public {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.locked(tid);
    }

    function test_Mint_EmitsLockedEvent() public {
        uint256 expectedTokenId = sbt.tokenIdOf(alice);

        vm.expectEmit(true, false, false, false);
        emit IERC5192.Locked(expectedTokenId);
        sbt.mint(alice);
    }

    function test_Burn_DoesNotEmitUnlocked() public {
        uint256 tokenId = sbt.mint(alice);

        vm.recordLogs();
        vm.prank(alice);
        sbt.burn(tokenId);

        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 unlockedSig = keccak256("Unlocked(uint256)");
        for (uint256 i = 0; i < logs.length; i++) {
            assertNotEq(logs[i].topics[0], unlockedSig);
        }
    }

    // ─── Cross-contract isolation ────────────────────────────────

    function test_CrossContract_TokenIdIsolation() public {
        AddressDerivedSBT sbt2 = new AddressDerivedSBT(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);

        uint256 tid1 = sbt.tokenIdOf(alice);
        uint256 tid2 = sbt2.tokenIdOf(alice);

        assertNotEq(tid1, tid2);
        assertEq(sbt.ownerOf(sbt.mint(alice)), alice);
        assertEq(sbt2.ownerOf(sbt2.mint(alice)), alice);
    }

    // ─── Fuzz ────────────────────────────────────────────────────

    function testFuzz_TokenIdOf_RoundTrip(address owner) public {
        uint256 tid = sbt.tokenIdOf(owner);
        sbt.mint(owner);
        assertEq(sbt.ownerOf(tid), owner);
        assertEq(sbt.balanceOf(owner), 1);
    }

    // ─── Gas ────────────────────────────────────────────────────

    function test_Gas_Mint() public {
        sbt.mint(alice);
    }

    function test_Gas_Burn() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);
    }
}
