// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../../access/OwnableBasic.sol";
import "./IRoyaltyPotDistribution.sol";
import "./eligibility/IEligibilityCheck.sol";
import "./eligibility/implementations/DefaultEligibilityCheck.sol";

/**
 * @title RoyaltyPotDistribution
 * @author Diluk Angelo (dilukangelo@gmail.com)
 * @notice Implementation of royalty pot distribution functionality
 */
abstract contract RoyaltyPotDistribution is IRoyaltyPotDistribution, OwnableBasic, ReentrancyGuard {
    using Address for address;

    // Distribution period in seconds
    uint256 private _distributionPeriod;
    bool private _distributionPeriodLocked;

    // Current distribution ID (increments with each new distribution)
    uint256 private _currentDistributionId;

    // Eligibility checker contract
    IEligibilityCheck private _eligibilityChecker;

    // Mapping from distribution ID to Distribution struct
    mapping(uint256 => Distribution) private _distributions;

    // Mapping from user address to distribution ID to claim info
    mapping(address => mapping(uint256 => UserClaim)) private _userClaims;

    /**
     * @notice Constructor sets up initial distribution period and eligibility checker
     * @param initialPeriod Initial distribution period in seconds
     */
    constructor(uint256 initialPeriod) {
        _setDistributionPeriod(initialPeriod);
        _eligibilityChecker = new DefaultEligibilityCheck();
    }

    /**
     * @notice Set the distribution period length
     * @dev Only callable by contract owner and when not locked
     * @param period New period length in seconds
     */
    function setDistributionPeriod(uint256 period) external override {
        _requireCallerIsContractOwner();
        require(!_distributionPeriodLocked, "Distribution period is locked");
        _setDistributionPeriod(period);
    }

    /**
     * @notice Lock the distribution period permanently
     * @dev Only callable by contract owner
     */
    function lockDistributionPeriod() external override {
        _requireCallerIsContractOwner();
        _distributionPeriodLocked = true;
        emit DistributionPeriodLocked();
    }

    /**
     * @notice Set the eligibility implementation
     * @dev Only callable by contract owner
     * @param implementation Address of the new eligibility checker
     */
    function setEligibilityImplementation(address implementation) external override {
        _requireCallerIsContractOwner();
        require(implementation.isContract(), "Implementation must be a contract");
        _eligibilityChecker = IEligibilityCheck(implementation);
        emit EligibilityImplementationSet(implementation);
    }

    /**
     * @notice Start a new distribution period
     * @dev Only callable by contract owner
     * @return uint256 ID of the new distribution
     */
    function startNewDistribution() external override returns (uint256) {
        _requireCallerIsContractOwner();
        
        uint256 newDistributionId = _currentDistributionId + 1;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _distributionPeriod;

        _distributions[newDistributionId] = Distribution({
            id: newDistributionId,
            startTime: startTime,
            endTime: endTime,
            totalAmount: 0, // Will be updated when royalties are received
            totalEligibleTokens: 0, // Will be updated based on eligible token count
            claimed: false
        });

        _currentDistributionId = newDistributionId;
        
        emit DistributionStarted(newDistributionId, startTime, endTime);
        return newDistributionId;
    }

    /**
     * @notice Allow users to claim their share of a distribution
     * @dev Requires the distribution to exist and user to be eligible
     * @param distributionId ID of the distribution to claim from
     */
    function claimDistribution(uint256 distributionId) external override nonReentrant {
        require(distributionId > 0 && distributionId <= _currentDistributionId, "Invalid distribution ID");
        Distribution storage dist = _distributions[distributionId];
        require(block.timestamp > dist.endTime, "Distribution period not ended");
        require(!_userClaims[msg.sender][distributionId].claimed, "Already claimed");
        require(checkEligibility(msg.sender), "Not eligible");

        uint256 eligibleTokens = _getEligibleTokenCount(msg.sender, dist.startTime);
        require(eligibleTokens > 0, "No eligible tokens");

        uint256 share = (dist.totalAmount * eligibleTokens) / dist.totalEligibleTokens;
        
        _userClaims[msg.sender][distributionId] = UserClaim({
            amount: share,
            eligibleTokens: eligibleTokens,
            claimed: true,
            claimTime: block.timestamp
        });

        // Transfer the share to the user
        _transferShare(msg.sender, share);
        
        emit DistributionClaimed(msg.sender, distributionId, share);
    }

    /**
     * @notice Get information about a distribution
     * @param distributionId ID of the distribution
     * @return Distribution struct containing distribution information
     */
    function getDistributionInfo(uint256 distributionId) external view override returns (Distribution memory) {
        require(distributionId > 0 && distributionId <= _currentDistributionId, "Invalid distribution ID");
        return _distributions[distributionId];
    }

    /**
     * @notice Get claim information for a user
     * @param user Address of the user
     * @param distributionId ID of the distribution
     * @return UserClaim struct containing claim information
     */
    function getUserClaimInfo(address user, uint256 distributionId) external view override returns (UserClaim memory) {
        require(distributionId > 0 && distributionId <= _currentDistributionId, "Invalid distribution ID");
        return _userClaims[user][distributionId];
    }

    /**
     * @notice Get the current distribution period
     * @return uint256 Distribution period in seconds
     */
    function getDistributionPeriod() external view override returns (uint256) {
        return _distributionPeriod;
    }

    /**
     * @notice Check if distribution period is locked
     * @return bool True if locked
     */
    function isDistributionPeriodLocked() external view override returns (bool) {
        return _distributionPeriodLocked;
    }

    /**
     * @notice Get the current distribution ID
     * @return uint256 Current distribution ID
     */
    function getCurrentDistributionId() external view override returns (uint256) {
        return _currentDistributionId;
    }

    /**
     * @notice Check if a user is eligible for distributions
     * @param user Address to check
     * @return bool True if eligible
     */
    function checkEligibility(address user) public view override returns (bool) {
        return _eligibilityChecker.isEligible(user);
    }

    /**
     * @notice Internal function to set distribution period
     * @param period New period length in seconds
     */
    function _setDistributionPeriod(uint256 period) private {
        require(period > 0, "Period must be greater than 0");
        _distributionPeriod = period;
        emit DistributionPeriodSet(period);
    }

    /**
     * @notice Get the number of eligible tokens for a user at a specific time
     * @dev Must be implemented by derived contracts
     * @param user Address of the user
     * @param timestamp Timestamp to check eligibility at
     * @return uint256 Number of eligible tokens
     */
    function _getEligibleTokenCount(address user, uint256 timestamp) internal virtual returns (uint256);

    /**
     * @notice Transfer share of royalties to user
     * @dev Must be implemented by derived contracts
     * @param to Address to transfer to
     * @param amount Amount to transfer
     */
    function _transferShare(address to, uint256 amount) internal virtual;

    /**
     * @notice Update total amount for current distribution period
     * @dev Called when royalties are received
     * @param amount Amount to add to current distribution
     */
    function _updateCurrentDistributionAmount(uint256 amount) internal {
        if (_currentDistributionId > 0) {
            Distribution storage currentDist = _distributions[_currentDistributionId];
            if (block.timestamp <= currentDist.endTime) {
                currentDist.totalAmount += amount;
            }
        }
    }

    /**
     * @notice Update total eligible tokens for current distribution period
     * @param totalTokens New total of eligible tokens
     */
    function _updateCurrentDistributionEligibleTokens(uint256 totalTokens) internal {
        if (_currentDistributionId > 0) {
            Distribution storage currentDist = _distributions[_currentDistributionId];
            if (block.timestamp <= currentDist.endTime) {
                currentDist.totalEligibleTokens = totalTokens;
            }
        }
    }
}