// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {TestUtility} from "./TestUtility.sol";
import {IERCXXXX} from "../contracts/interfaces/IERCXXXX.sol";

contract ERC721MetadataTest is TestUtility {
    function test_Name() external view {
        assertEq(sbt.name(), TOKEN_NAME);
    }

    function test_Symbol() external view {
        assertEq(sbt.symbol(), TOKEN_SYMBOL);
    }

    function test_TokenURI_ReturnsBaseURI() external {
        uint256 tokenId = sbt.mint(alice);
        assertEq(sbt.tokenURI(tokenId), BASE_URI);
    }

    function test_TokenURI_ReturnsBaseURIAfterReMint() external {
        uint256 tokenId = sbt.mint(alice);

        vm.prank(alice);
        sbt.burn(tokenId);

        sbt.mint(alice);

        assertEq(sbt.tokenURI(tokenId), BASE_URI);
    }

    function test_TokenURI_RevertWhenNotMinted() external {
        uint256 tid = sbt.tokenIdOf(bob);
        vm.expectRevert(IERCXXXX.NotMinted.selector);
        sbt.tokenURI(tid);
    }
}
