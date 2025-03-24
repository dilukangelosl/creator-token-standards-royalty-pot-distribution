// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./templates/constructable/erc721c/ERC721CMetadata.sol";

contract MockERC721C is ERC721CMetadata {
    uint256 private _currentTokenId;
    mapping(uint256 => uint256) private _ownedTokens;
    mapping(address => uint256[]) private _ownedTokensByAddress;

    error IndexOutOfBounds();

    constructor() ERC721CMetadata("MockERC721C", "MC721C") {}

    function mint(address to) external returns (uint256) {
        _currentTokenId++;
        _mint(to, _currentTokenId);
        _addToOwnerEnumeration(to, _currentTokenId);
        return _currentTokenId;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://mock.uri/";
    }

    // Enumerable extension functions
    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        if (index >= balanceOf(owner)) revert IndexOutOfBounds();
        return _ownedTokensByAddress[owner][index];
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        if (index >= totalSupply()) revert IndexOutOfBounds();
        return index + 1; // Since we mint sequentially
    }

    function _addToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokens[tokenId] = _ownedTokensByAddress[to].length;
        _ownedTokensByAddress[to].push(tokenId);
    }

    function _removeFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _ownedTokensByAddress[from].length - 1;
        uint256 tokenIndex = _ownedTokens[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokensByAddress[from][lastTokenIndex];
            _ownedTokensByAddress[from][tokenIndex] = lastTokenId;
            _ownedTokens[lastTokenId] = tokenIndex;
        }

        _ownedTokensByAddress[from].pop();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, 1);

        if (from != address(0)) {
            _removeFromOwnerEnumeration(from, tokenId);
        }
        if (to != address(0)) {
            _addToOwnerEnumeration(to, tokenId);
        }
    }
}