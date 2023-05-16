// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { ERC1155Burnable } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import { ERC1155URIStorage } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC1155Supply } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract MyToken is ERC1155, ERC1155Burnable, ERC1155URIStorage, AccessControl, ERC1155Supply {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    bool public transfersEnabled = false;

    mapping(uint8 => uint16) tokenMaxSupply;

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function createToken(uint8 id, uint16 maxSupply, string memory tokenURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(tokenMaxSupply[id] == 0, "Token already exists");
        tokenMaxSupply[id] = maxSupply;
        _setURI(id, tokenURI);
    }

    function mint(address recipient, uint8 id, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(tokenMaxSupply[id] != 0, "Token doesn't exist");
        require(totalSupply(id) + amount <= tokenMaxSupply[id], "Amount exceeds max supply");
        _mint(recipient, id, amount, "");
    }

    function mint(address recipient, uint8 id) public onlyRole(MINTER_ROLE) {
        require(tokenMaxSupply[id] != 0, "Token doesn't exist");
        require(totalSupply(id) + 1 <= tokenMaxSupply[id], "Amount exceeds max supply");
        _mint(recipient, id, 1, "");
    }

    // In this implementation this is one-way: once transfers are enabled, they cannot be disabled again
    function enableTransfers() external onlyRole(DEFAULT_ADMIN_ROLE) {
        transfersEnabled = true;
    }

    /// @dev override required by Solidity.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        // Do the following check if transfers are not enabled yet
        if (!transfersEnabled) {
            // from address has to be either the zero address (mint event), the owner or someone with TRANSFER_ROLE
            require(from == address(0) || hasRole(DEFAULT_ADMIN_ROLE, from) || hasRole(TRANSFER_ROLE, from), "ERC1155: transfers not enabled");
        }
    }

    /// @dev override required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @dev override required by Solidity.
    function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }
}
