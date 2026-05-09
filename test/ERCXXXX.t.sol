// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {TestUtility} from "./TestUtility.sol";
import {AddressDerivedSBT} from "../contracts/AddressDerivedSBT.sol";
import {IERC721Core, IERCXXXX} from "../contracts/interfaces/IERCXXXX.sol";

contract ERCXXXXTest is TestUtility {
    // ─── Mint ───────────────────────────────────────────────────

    function test_Mint_Success() external {
        uint256 tokenId = sbt.mint(alice);

        uint256 expectedTokenId = sbt.tokenIdOf(alice);
        assertEq(tokenId, expectedTokenId);
        assertEq(sbt.ownerOf(tokenId), alice);
        assertEq(sbt.balanceOf(alice), 1);
    }

    function test_Mint_RevertWhen_AlreadyMinted() external {
        sbt.mint(alice);

        vm.expectRevert(IERCXXXX.AlreadyMinted.selector);
        sbt.mint(alice);
    }

    function test_Mint_EmitsTransferEvent() external {
        uint256 expectedTokenId = sbt.tokenIdOf(alice);

        vm.expectEmit(true, true, true, true);
        emit IERC721Core.Transfer(address(0), alice, expectedTokenId);
        sbt.mint(alice);
    }

    function test_Mint_AllowsMintToZeroAddress() external {
        uint256 tid = sbt.mint(address(0));

        uint256 expectedTid = sbt.tokenIdOf(address(0));
        assertEq(tid, expectedTid);
        assertEq(sbt.ownerOf(tid), address(0));
        assertEq(sbt.balanceOf(address(0)), 1);
    }

    function test_Mint_AllowsAnyAddressToMintForAlice() external {
        vm.prank(bob);
        uint256 tokenId = sbt.mint(alice);

        assertEq(sbt.ownerOf(tokenId), alice);
    }

    // ─── Burn ───────────────────────────────────────────────────

    function test_Burn_ByOwner() external {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.balanceOf(alice), 1);

        vm.prank(alice);
        sbt.burn(tokenId);

        assertEq(sbt.balanceOf(alice), 0);
    }

    function test_Burn_RevertWhen_NotOwner() external {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(bob);
        vm.expectRevert(IERCXXXX.NotAuthorized.selector);
        sbt.burn(tokenId);
    }

    function test_Burn_RevertWhen_NotMinted() external {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.burn(tid);
    }

    function test_Burn_EmitsTransferEvent() external {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit IERC721Core.Transfer(alice, address(0), tokenId);
        sbt.burn(tokenId);
    }

    function test_Burn_AllowsReMint() external {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        sbt.mint(alice);

        assertEq(sbt.balanceOf(alice), 1);
    }

    // ─── tokenIdOf ─────────────────────────────────────────────

    function test_TokenIdOf_ReturnsDeterministicValue() external view {
        uint256 tid = sbt.tokenIdOf(alice);
        uint256 expected = uint256(uint160(alice)) ^ uint256(uint160(address(sbt)));
        assertEq(tid, expected);
    }

    function test_TokenIdOf_ZeroAddress() external view {
        uint256 tid = sbt.tokenIdOf(address(0));
        uint256 expected = 0 ^ uint256(uint160(address(sbt)));
        assertEq(tid, expected);
    }

    function test_TokenIdOf_RoundTrip() external {
        address owner = alice;
        uint256 tid = sbt.tokenIdOf(owner);
        assertEq(sbt.balanceOf(owner), 0);
        sbt.mint(owner);
        assertEq(sbt.balanceOf(owner), 1);
        assertEq(sbt.ownerOf(tid), owner);
    }

    function test_TokenIdOf_ConsistentAcrossCalls() external view {
        assertEq(sbt.tokenIdOf(alice), sbt.tokenIdOf(alice));
    }

    function test_TokenIdOf_ConsistentAfterReMint() external {
        uint256 tokenIdBefore = sbt.tokenIdOf(alice);
        uint256 tid = sbt.mint(alice);
        assertEq(tid, tokenIdBefore);

        vm.prank(alice);
        sbt.burn(tid);

        uint256 tokenIdAfter = sbt.tokenIdOf(alice);
        assertEq(tokenIdAfter, tokenIdBefore);

        uint256 tid2 = sbt.mint(alice);
        assertEq(tid2, tokenIdBefore);
    }

    // ─── Multiple Addresses ───────────────────────────────────

    function test_MultipleAddresses() external {
        sbt.mint(alice);
        sbt.mint(bob);
        assertEq(sbt.balanceOf(alice), 1);
        assertEq(sbt.balanceOf(bob), 1);
        assertNotEq(sbt.tokenIdOf(alice), sbt.tokenIdOf(bob));
    }

    // ─── Cross-contract isolation ────────────────────────────────

    function test_CrossContract_TokenIdIsolation() external {
        AddressDerivedSBT sbt2 = new AddressDerivedSBT(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);

        uint256 tid1 = sbt.tokenIdOf(alice);
        uint256 tid2 = sbt2.tokenIdOf(alice);

        assertNotEq(tid1, tid2);
        assertEq(sbt.ownerOf(sbt.mint(alice)), alice);
        assertEq(sbt2.ownerOf(sbt2.mint(alice)), alice);
    }

    // ─── Fuzz ────────────────────────────────────────────────────

    function testFuzz_RoundTrip(address owner) external {
        uint256 tid = sbt.tokenIdOf(owner);

        sbt.mint(owner);
        assertEq(sbt.ownerOf(tid), owner);
        assertEq(sbt.balanceOf(owner), 1);
        assertEq(sbt.locked(tid), true);

        if (owner != address(0)) {
            vm.prank(owner);
            sbt.burn(tid);
            assertEq(sbt.balanceOf(owner), 0);
        }
    }
}
