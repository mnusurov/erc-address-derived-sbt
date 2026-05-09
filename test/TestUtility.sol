// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {Test, Vm} from "forge-std/Test.sol";

import {AddressDerivedSBT} from "../contracts/AddressDerivedSBT.sol";
import {
    IERC165,
    IERC5192,
    IERC721Core,
    IERC721Metadata,
    IERCXXXX
} from "../contracts/interfaces/IERCXXXX.sol";

abstract contract TestUtility is Test {
    AddressDerivedSBT internal sbt;
    address internal alice;
    address internal bob;

    string internal constant TOKEN_NAME = "Address-Derived SBT";
    string internal constant TOKEN_SYMBOL = "ADSBT";
    string internal constant BASE_URI = "https://example.com/metadata/";

    function setUp() external virtual {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        sbt = new AddressDerivedSBT(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);
    }
}
