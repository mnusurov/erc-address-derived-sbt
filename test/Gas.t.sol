// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.35;

import {TestUtility} from "./TestUtility.sol";
import {AddressDerivedSBT} from "../contracts/AddressDerivedSBT.sol";
import {console} from "forge-std/console.sol";

contract GasTest is TestUtility {
    function setUp() external override {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        sbt = new AddressDerivedSBT(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);
        sbt.mint(alice);
    }

    function test_Burn() external {
        uint256 tid = sbt.tokenIdOf(alice);
        vm.prank(alice);
        vm.startSnapshotGas("burn");
        sbt.burn(tid);
        uint256 gasUsed = vm.stopSnapshotGas();
        console.log("Burn gas:", gasUsed);
    }

    function test_Mint() external {
        vm.startSnapshotGas("mint");
        sbt.mint(bob);
        uint256 gasUsed = vm.stopSnapshotGas();
        console.log("Mint gas:", gasUsed);
    }

    function test_BalanceOf() external {
        vm.startSnapshotGas("balanceOf");
        sbt.balanceOf(alice);
        uint256 gasUsed = vm.stopSnapshotGas();
        console.log("BalanceOf gas:", gasUsed);
    }

    function test_OwnerOf() external {
        vm.startSnapshotGas("ownerOf");
        sbt.ownerOf(sbt.tokenIdOf(alice));
        uint256 gasUsed = vm.stopSnapshotGas();
        console.log("OwnerOf gas:", gasUsed);
    }

    function test_TokenIdOf() external {
        vm.startSnapshotGas("tokenIdOf");
        sbt.tokenIdOf(alice);
        uint256 gasUsed = vm.stopSnapshotGas();
        console.log("TokenIdOf gas:", gasUsed);
    }
}
