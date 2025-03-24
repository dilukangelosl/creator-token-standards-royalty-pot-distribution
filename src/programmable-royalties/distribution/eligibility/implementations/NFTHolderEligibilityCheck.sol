// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IEligibilityCheck.sol";

/**
 * @title NFTHolderEligibilityCheck
 * @author Diluk Angelo (dilukangelo@gmail.com)
 * @notice Eligibility implementation that checks if users hold NFTs from specified collections
 */
contract NFTHolderEligibilityCheck is IEligibilityCheck, Ownable {
    // Array of NFT contracts to check for eligibility
    IERC721[] private _eligibleCollections;
    
    // Minimum number of NFTs required across all collections
    uint256 private _minRequiredBalance;

    event EligibleCollectionAdded(address indexed collection);
    event EligibleCollectionRemoved(address indexed collection);
    event MinRequiredBalanceUpdated(uint256 newMinBalance);

    /**
     * @notice Constructor
     * @param initialMinBalance Minimum number of NFTs required
     */
    constructor(uint256 initialMinBalance) {
        _minRequiredBalance = initialMinBalance;
    }

    /**
     * @notice Add an NFT collection to eligibility check
     * @param collection Address of the NFT collection
     */
    function addEligibleCollection(address collection) external onlyOwner {
        require(collection != address(0), "Collection cannot be zero address");
        for (uint i = 0; i < _eligibleCollections.length; i++) {
            require(address(_eligibleCollections[i]) != collection, "Collection already added");
        }
        _eligibleCollections.push(IERC721(collection));
        emit EligibleCollectionAdded(collection);
    }

    /**
     * @notice Remove an NFT collection from eligibility check
     * @param collection Address of the NFT collection to remove
     */
    function removeEligibleCollection(address collection) external onlyOwner {
        require(collection != address(0), "Collection cannot be zero address");
        for (uint i = 0; i < _eligibleCollections.length; i++) {
            if (address(_eligibleCollections[i]) == collection) {
                _eligibleCollections[i] = _eligibleCollections[_eligibleCollections.length - 1];
                _eligibleCollections.pop();
                emit EligibleCollectionRemoved(collection);
                return;
            }
        }
        revert("Collection not found");
    }

    /**
     * @notice Set minimum required balance across all collections
     * @param newMinBalance New minimum balance required
     */
    function setMinRequiredBalance(uint256 newMinBalance) external onlyOwner {
        require(newMinBalance > 0, "Min balance must be greater than 0");
        _minRequiredBalance = newMinBalance;
        emit MinRequiredBalanceUpdated(newMinBalance);
    }

    /**
     * @notice Check if a user is eligible based on NFT holdings
     * @param user Address to check eligibility for
     * @return bool True if user holds required number of NFTs across eligible collections
     */
    function isEligible(address user) external view override returns (bool) {
        require(user != address(0), "Cannot check zero address");
        
        // If no collections set, everyone is eligible
        if (_eligibleCollections.length == 0) {
            return true;
        }

        uint256 totalBalance = 0;
        
        for (uint i = 0; i < _eligibleCollections.length; i++) {
            totalBalance += _eligibleCollections[i].balanceOf(user);
            // Short circuit if we reach the minimum required balance
            if (totalBalance >= _minRequiredBalance) {
                return true;
            }
        }

        return false;
    }

    /**
     * @notice Get all eligible collections
     * @return IERC721[] Array of eligible collection addresses
     */
    function getEligibleCollections() external view returns (IERC721[] memory) {
        return _eligibleCollections;
    }

    /**
     * @notice Get minimum required balance
     * @return uint256 Minimum number of NFTs required
     */
    function getMinRequiredBalance() external view returns (uint256) {
        return _minRequiredBalance;
    }
}