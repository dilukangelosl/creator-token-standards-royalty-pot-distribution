# Quick Start Guide - ERC721C Royalty Pot Distribution

## 5-Minute Setup

### 1. Install

```bash
forge install creator-token-standards-royalty-pot-distribution
```

### 2. Deploy

```solidity
import "@creator-token-standards/erc721c/RoyaltyPotDistribution.sol";

// Deploy with 30-day distribution period
ERC721RoyaltyPotDistribution distribution = new ERC721RoyaltyPotDistribution(
    address(yourERC721C),
    30 days
);
```

### 3. Configure Eligibility

```solidity
// Basic NFT holder eligibility
NFTHolderEligibilityCheck eligibility = new NFTHolderEligibilityCheck(1);
eligibility.addEligibleCollection(address(yourERC721C));
distribution.setEligibilityImplementation(address(eligibility));
```

### 4. Start Distribution

```solidity
// Start first period
uint256 distributionId = distribution.startNewDistribution();
```

### 5. Send Royalties

```solidity
// From your marketplace contract or manually
payable(address(distribution)).transfer(amount);
```

### 6. Users Claim

```solidity
// After period ends
distribution.claimDistribution(distributionId);
```

## Common Operations

### Check Eligibility
```solidity
bool isEligible = distribution.checkEligibility(userAddress);
```

### View Distribution Info
```solidity
Distribution info = distribution.getDistributionInfo(distributionId);
```

### Check User Claims
```solidity
UserClaim claim = distribution.getUserClaimInfo(userAddress, distributionId);
```

## Need Help?

- Full Documentation: See README.md
- Examples: See test/RoyaltyPotDistribution.t.sol
- Issues: Create a GitHub issue

## Security Notes

- Always test with small amounts first
- Verify contract addresses carefully
- Check eligibility rules before deployment
- Monitor distribution periods