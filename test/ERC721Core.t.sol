// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {TestUtility} from "./TestUtility.sol";
import {IERCXXXX} from "../contracts/interfaces/IERCXXXX.sol";

contract ERC721CoreTest is TestUtility {
    function test_BalanceOf_ReturnsOneForMintedAddress() external {
        sbt.mint(alice);
        assertEq(sbt.balanceOf(alice), 1);
    }

    function test_BalanceOf_ReturnsZeroAfterBurn() external {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        assertEq(sbt.balanceOf(alice), 0);
    }

    function test_BalanceOf_ReturnsZeroForUnmintedAddress() external view {
        assertEq(sbt.balanceOf(bob), 0);
    }

    function test_BalanceOf_ReturnsZeroForZeroAddress() external view {
        assertEq(sbt.balanceOf(address(0)), 0);
    }

    function test_OwnerOf_ReturnsOwnerWhenMinted() external {
        sbt.mint(alice);
        assertEq(sbt.ownerOf(sbt.tokenIdOf(alice)), alice);
    }

    function test_OwnerOf_RevertAfterBurn() external {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.ownerOf(tokenId);
    }

    function test_OwnerOf_RevertWhenNotMinted() external {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.ownerOf(tid);
    }
}
