// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../src/programmable-royalties/distribution/implementations/ERC721RoyaltyPotDistribution.sol";

contract TestableRoyaltyPotDistribution is ERC721RoyaltyPotDistribution {
    constructor(
        address nftContract,
        uint256 initialPeriod
    ) ERC721RoyaltyPotDistribution(nftContract, initialPeriod) {}

    // Expose functions for testing
    function exposed_updateDistribution(uint256 amount) external {
        _updateCurrentDistributionAmount(amount);
        _updateCurrentDistributionEligibleTokens(_getSupply());
    }

    function _getSupply() private view returns (uint256) {
        bytes memory data = abi.encodeWithSignature("totalSupply()");
        (bool success, bytes memory returnData) = _nftContract.staticcall(data);
        require(success, "Supply check failed");
        return abi.decode(returnData, (uint256));
    }
}