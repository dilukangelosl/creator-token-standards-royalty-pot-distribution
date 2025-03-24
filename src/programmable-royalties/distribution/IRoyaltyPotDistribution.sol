// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title IRoyaltyPotDistribution
 * @author Diluk Angelo (dilukangelo@gmail.com)
 * @notice Interface for royalty pot distribution functionality
 */
interface IRoyaltyPotDistribution {
    /**
     * @notice Structure to store distribution information
     * @param id Unique identifier for the distribution
     * @param startTime Start timestamp of the distribution period
     * @param endTime End timestamp of the distribution period
     * @param totalAmount Total amount of royalties to distribute
     * @param totalEligibleTokens Total number of tokens eligible for distribution
     * @param claimed Whether the distribution has been claimed
     */
    struct Distribution {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 totalAmount;
        uint256 totalEligibleTokens;
        bool claimed;
    }

    /**
     * @notice Structure to store user claim information
     * @param amount Amount of royalties claimed
     * @param eligibleTokens Number of tokens eligible at time of claim
     * @param claimed Whether the user has claimed their share
     * @param claimTime Timestamp when the claim was made
     */
    struct UserClaim {
        uint256 amount;
        uint256 eligibleTokens;
        bool claimed;
        uint256 claimTime;
    }

    /**
     * @notice Emitted when distribution period is set
     * @param newPeriod New distribution period length in seconds
     */
    event DistributionPeriodSet(uint256 newPeriod);

    /**
     * @notice Emitted when distribution period is permanently locked
     */
    event DistributionPeriodLocked();

    /**
     * @notice Emitted when eligibility implementation is updated
     * @param implementation New eligibility implementation address
     */
    event EligibilityImplementationSet(address implementation);

    /**
     * @notice Emitted when a new distribution period starts
     * @param distributionId Unique identifier for the distribution
     * @param startTime Start timestamp of the distribution period
     * @param endTime End timestamp of the distribution period
     */
    event DistributionStarted(uint256 indexed distributionId, uint256 startTime, uint256 endTime);

    /**
     * @notice Emitted when a user claims their share of a distribution
     * @param user Address of the user claiming
     * @param distributionId ID of the distribution being claimed
     * @param amount Amount of royalties claimed
     */
    event DistributionClaimed(address indexed user, uint256 indexed distributionId, uint256 amount);

    /**
     * @notice Set the length of the distribution period
     * @param period New period length in seconds
     */
    function setDistributionPeriod(uint256 period) external;

    /**
     * @notice Permanently lock the distribution period length
     */
    function lockDistributionPeriod() external;

    /**
     * @notice Set the implementation for eligibility checking
     * @param implementation Address of the eligibility implementation contract
     */
    function setEligibilityImplementation(address implementation) external;

    /**
     * @notice Start a new distribution period
     * @return uint256 ID of the new distribution period
     */
    function startNewDistribution() external returns (uint256);

    /**
     * @notice Claim user's share from a specific distribution
     * @param distributionId ID of the distribution to claim from
     */
    function claimDistribution(uint256 distributionId) external;

    /**
     * @notice Get information about a specific distribution
     * @param distributionId ID of the distribution
     * @return Distribution struct containing distribution information
     */
    function getDistributionInfo(uint256 distributionId) external view returns (Distribution memory);

    /**
     * @notice Get claim information for a specific user and distribution
     * @param user Address of the user
     * @param distributionId ID of the distribution
     * @return UserClaim struct containing claim information
     */
    function getUserClaimInfo(address user, uint256 distributionId) external view returns (UserClaim memory);

    /**
     * @notice Check current distribution period
     * @return uint256 Current distribution period length in seconds
     */
    function getDistributionPeriod() external view returns (uint256);

    /**
     * @notice Check if distribution period is locked
     * @return bool True if the distribution period is locked
     */
    function isDistributionPeriodLocked() external view returns (bool);

    /**
     * @notice Get the current distribution ID
     * @return uint256 Current distribution ID
     */
    function getCurrentDistributionId() external view returns (uint256);

    /**
     * @notice Check if a user is eligible for distributions
     * @param user Address to check
     * @return bool True if the user is eligible
     */
    function checkEligibility(address user) external view returns (bool);
}