// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { MyToken } from "../contracts/MyToken.sol";
import { EasyAuctionMock } from "../contracts/test/EasyAuctionMock.sol";

contract TokenTest is Test {
    MyToken internal token;
    EasyAuctionMock internal easyAuction;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address deployer = makeAddr("bighead");

    function setUp() public {
        vm.startPrank(deployer);
        token = new MyToken();

        token.mint(deployer, 1, 250, "ar://ergiuehrgiuerhg");

        easyAuction = new EasyAuctionMock(address(token));
        token.safeTransferFrom(deployer, alice, 1, 1, "");
        vm.stopPrank();
    }

    function testTokenSupplyAndMetadata() public {
        assertEq(token.totalSupply(1), 250);
        assertEq(token.balanceOf(deployer, 1), 249);
        assertEq(token.balanceOf(alice, 1), 1);
        assertEq(token.uri(1), "ar://ergiuehrgiuerhg");
    }

    function testTransfersDisabled() public {
        vm.startPrank(alice);
        vm.expectRevert("ERC1155: transfers not enabled");
        token.safeTransferFrom(alice, bob, 1, 1, "");
        vm.stopPrank();
    }

    function testTransfersEnabled() public {
        vm.startPrank(deployer);
        token.enableTransfers();
        vm.stopPrank();

        vm.startPrank(alice);
        token.safeTransferFrom(alice, bob, 1, 1, "");
        assertEq(token.balanceOf(alice, 1), 0);
        assertEq(token.balanceOf(bob, 1), 1);
        vm.stopPrank();
    }

    function testModeratorCanTransfer() public {
        vm.startPrank(deployer);
        token.grantRole(token.TRANSFER_ROLE(), alice);
        assert(token.hasRole(token.TRANSFER_ROLE(), alice));
        vm.stopPrank();

        vm.startPrank(alice);
        token.safeTransferFrom(alice, bob, 1, 1, "");
        assertEq(token.balanceOf(alice, 1), 0);
        assertEq(token.balanceOf(bob, 1), 1);
        vm.stopPrank();
    }

    function testContractCannotTransfer() public {
        vm.startPrank(deployer);
        token.safeTransferFrom(deployer, address(easyAuction), 1, 1, "");
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("ERC1155: transfers not enabled");
        easyAuction.transferSomething(address(easyAuction), bob, 1, 1);
        vm.stopPrank();
    }

    function testModeratorContractCanTransfer() public {
        vm.startPrank(deployer);
        token.grantRole(token.TRANSFER_ROLE(), address(easyAuction));
        token.safeTransferFrom(deployer, address(easyAuction), 1, 1, "");
        assert(token.hasRole(token.TRANSFER_ROLE(), address(easyAuction)));
        vm.stopPrank();

        vm.startPrank(bob);
        easyAuction.transferSomething(address(easyAuction), bob, 1, 1);
        vm.stopPrank();

        assertEq(token.balanceOf(address(easyAuction), 1), 0);
        assertEq(token.balanceOf(bob, 1), 1);
    }
}
