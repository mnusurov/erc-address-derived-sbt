// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {TestUtility} from "./TestUtility.sol";
import {Vm} from "forge-std/Test.sol";
import {IERC5192, IERCXXXX} from "../contracts/interfaces/IERCXXXX.sol";

contract ERC5192Test is TestUtility {
    function test_Locked_ReturnsTrueWhenMinted() external {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.locked(tokenId), true);
    }

    function test_Locked_RevertsWhenNotMinted() external {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.locked(tid);
    }

    function test_Mint_EmitsLockedEvent() external {
        uint256 expectedTokenId = sbt.tokenIdOf(alice);

        vm.expectEmit(true, false, false, false);
        emit IERC5192.Locked(expectedTokenId);
        sbt.mint(alice);
    }

    function test_Mint_EmitsLockedEventOnReMint() external {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.ownerOf(tokenId), alice);
        assertEq(sbt.balanceOf(alice), 1);

        vm.prank(alice);
        sbt.burn(tokenId);
        assertEq(sbt.balanceOf(alice), 0);

        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.ownerOf(tokenId);

        uint256 expectedTokenId = sbt.tokenIdOf(alice);
        vm.expectEmit(true, false, false, false);
        emit IERC5192.Locked(expectedTokenId);
        sbt.mint(alice);

        assertEq(sbt.balanceOf(alice), 1);
        assertEq(sbt.ownerOf(expectedTokenId), alice);
    }

    function test_Burn_DoesNotEmitUnlocked() external {
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
}
