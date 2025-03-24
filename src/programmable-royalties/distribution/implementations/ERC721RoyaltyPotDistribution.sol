// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../RoyaltyPotDistribution.sol";

contract ERC721RoyaltyPotDistribution is RoyaltyPotDistribution {
    address internal immutable _nftContract;

    error BalanceCheckFailed();
    error SupplyCheckFailed();
    error NoTokensMinted();
    error TransferFailed();

    constructor(
        address nftContract,
        uint256 initialPeriod
    ) RoyaltyPotDistribution(initialPeriod) {
        require(nftContract != address(0), "NFT contract cannot be zero address");
        require(nftContract.code.length > 0, "NFT contract must be a contract");
        _nftContract = nftContract;
    }

    function _getEligibleTokenCount(address user, uint256) internal view override returns (uint256) {
        bytes memory data = abi.encodeWithSignature("balanceOf(address)", user);
        (bool success, bytes memory returnData) = _nftContract.staticcall(data);
        if (!success) revert BalanceCheckFailed();
        return abi.decode(returnData, (uint256));
    }

    function _transferShare(address to, uint256 amount) internal override {
        require(to != address(0), "Cannot transfer to zero address");
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    receive() external payable {
        bytes memory data = abi.encodeWithSignature("totalSupply()");
        (bool success, bytes memory returnData) = _nftContract.staticcall(data);
        if (!success) revert SupplyCheckFailed();
        
        uint256 supply = abi.decode(returnData, (uint256));
        if (supply == 0) revert NoTokensMinted();

        _updateCurrentDistributionAmount(msg.value);
        _updateCurrentDistributionEligibleTokens(supply);
    }
}