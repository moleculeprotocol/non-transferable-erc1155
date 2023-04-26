// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EasyAuctionMock {
    address private _token;

    constructor(address token) {
        _token = token;
    }

    function transferSomething(address from, address to, uint256 tokenId, uint256 amount) public {
        ERC1155(_token).safeTransferFrom(from, to, tokenId, amount, "");
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
