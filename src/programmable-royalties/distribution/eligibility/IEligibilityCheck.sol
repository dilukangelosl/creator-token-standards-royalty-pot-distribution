// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title IEligibilityCheck
 * @author Diluk Angelo (dilukangelo@gmail.com)
 * @notice Interface for implementing custom eligibility logic for royalty distributions
 */
interface IEligibilityCheck {
    /**
     * @notice Check if an address is eligible for royalty distribution
     * @param user Address to check eligibility for
     * @return bool True if the address is eligible, false otherwise
     */
    function isEligible(address user) external view returns (bool);
}