// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
}