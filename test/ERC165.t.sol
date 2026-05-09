// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {TestUtility} from "./TestUtility.sol";
import {IERCXXXX, IERC165, IERC5192, IERC721Metadata} from "../contracts/interfaces/IERCXXXX.sol";

contract ERC165Test is TestUtility {
    function test_SupportsInterface_IERCXXXX() external view {
        assertEq(sbt.supportsInterface(type(IERCXXXX).interfaceId), true);
    }

    function test_InterfaceId_IERCXXXX_Correct() external pure {
        assertEq(type(IERCXXXX).interfaceId, bytes4(0x5fc816fe));
    }

    function test_SupportsInterface_IERC165() external view {
        assertEq(sbt.supportsInterface(type(IERC165).interfaceId), true);
    }

    function test_SupportsInterface_IERC5192() external view {
        assertEq(sbt.supportsInterface(type(IERC5192).interfaceId), true);
    }

    function test_SupportsInterface_IERC721Metadata() external view {
        assertEq(sbt.supportsInterface(type(IERC721Metadata).interfaceId), true);
    }

    function test_SupportsInterface_ReturnsFalseForUnknown() external view {
        assertEq(sbt.supportsInterface(0xdeadbeef), false);
    }
}
