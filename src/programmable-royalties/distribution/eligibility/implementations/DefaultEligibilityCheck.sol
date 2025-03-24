// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../IEligibilityCheck.sol";

/**
 * @title DefaultEligibilityCheck
 * @author Diluk Angelo (dilukangelo@gmail.com)
 * @notice Default implementation of eligibility checking that allows all users
 */
contract DefaultEligibilityCheck is IEligibilityCheck {
    /**
     * @notice Default implementation that allows all users
     * @param user Address to check eligibility for (unused in default implementation)
     * @return bool Always returns true
     */
    function isEligible(address user) external pure returns (bool) {
        return true;
    }
}