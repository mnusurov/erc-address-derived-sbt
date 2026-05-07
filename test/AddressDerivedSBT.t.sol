// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {Test} from "forge-std/Test.sol";
import {AddressDerivedSBT} from "../contracts/AddressDerivedSBT.sol";
import {IERCXXXX} from "../contracts/interfaces/IERCXXXX.sol";

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

        uint256 expectedTokenId = uint256(uint160(alice));
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
        uint256 expectedTokenId = uint256(uint160(alice));

        vm.expectEmit(true, true, true, true);
        emit IERCXXXX.Transfer(address(0), alice, expectedTokenId);
        sbt.mint(alice);
    }

    function test_Mint_AllowsMintToZeroAddress() public {
        sbt.mint(address(0));

        assertEq(sbt.ownerOf(0), address(0));
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

        vm.prank(alice);
        sbt.burn(tokenId);

        assertEq(sbt.ownerOf(tokenId), address(0));
        assertEq(sbt.balanceOf(alice), 0);
    }

    function test_Burn_RevertWhen_NotOwner() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(bob);
        vm.expectRevert(IERCXXXX.NotAuthorized.selector);
        sbt.burn(tokenId);
    }

    function test_Burn_RevertWhen_NotMinted() public {
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.burn(uint256(uint160(bob)));
    }

    function test_Burn_EmitsTransferEvent() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit IERCXXXX.Transfer(alice, address(0), tokenId);
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

    function test_OwnerOf_ReturnsZeroWhenNotMinted() public view {
        assertEq(sbt.ownerOf(uint256(uint160(bob))), address(0));
    }

    function test_OwnerOf_ReturnsOwnerWhenMinted() public {
        sbt.mint(alice);
        assertEq(sbt.ownerOf(uint256(uint160(alice))), alice);
    }

    function test_OwnerOf_ReturnsZeroAfterBurn() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        assertEq(sbt.ownerOf(tokenId), address(0));
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
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.tokenURI(uint256(uint160(bob)));
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

    // ─── Reverts ────────────────────────────────────────────────

    function test_RevertBurnByNonOwner() public {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(bob);
        vm.expectRevert(IERCXXXX.NotAuthorized.selector);
        sbt.burn(tokenId);
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
