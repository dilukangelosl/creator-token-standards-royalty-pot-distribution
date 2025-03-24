# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of ERC721C Royalty Pot Distribution system seriously. If you believe you have found a security vulnerability, please report it to us through coordinated disclosure.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please send email to security@limitbreak.com

### Process

1. Email your findings to security@limitbreak.com
2. Include detailed steps to reproduce the vulnerability
3. Our security team will acknowledge receipt within 24 hours
4. We will send a detailed response within 72 hours
5. We will keep you informed of the progress towards a fix
6. Once the issue is resolved, we will publish a security advisory

## Security Considerations

### Smart Contract Security

1. **Access Control**
   - Admin functions properly protected
   - Eligibility checks implemented correctly
   - Distribution claims validated

2. **Token Security**
   - Token balance checks
   - Token transfer validation
   - NFT ownership verification

3. **ETH Handling**
   - Secure ETH transfers
   - Balance tracking
   - Distribution calculations

4. **State Management**
   - Distribution period tracking
   - Claim status tracking
   - Period locking mechanism

### Known Security Guarantees

The system provides the following security guarantees:

1. **Distribution Integrity**
   - No double claims
   - Accurate share calculation
   - Protected distribution periods

2. **Access Control**
   - Only owner can start distributions
   - Only eligible users can claim
   - Locked periods cannot be modified

3. **Asset Safety**
   - ETH safely stored
   - Secure transfer mechanisms
   - Protected claim process

### Security Best Practices for Integration

When integrating the Royalty Pot Distribution system:

1. **Deployment**
   ```solidity
   // Always verify contract addresses
   require(address(nftContract).code.length > 0, "Invalid contract");
   
   // Set proper initial period
   require(period > minimumPeriod, "Period too short");
   
   // Validate eligibility implementation
   require(address(eligibility).isContract(), "Invalid eligibility");
   ```

2. **Operation**
   ```solidity
   // Monitor distribution status
   function checkDistribution(uint256 id) external view {
       Distribution memory dist = distribution.getDistributionInfo(id);
       require(dist.totalAmount > 0, "No funds");
       require(dist.totalEligibleTokens > 0, "No eligible tokens");
   }
   
   // Verify claims
   function validateClaim(address user, uint256 id) external view {
       require(!distribution.getUserClaimInfo(user, id).claimed, "Already claimed");
       require(distribution.checkEligibility(user), "Not eligible");
   }
   ```

3. **Monitoring**
   ```solidity
   // Track distribution events
   event DistributionStatus(
       uint256 indexed id,
       uint256 totalAmount,
       uint256 remainingAmount
   );
   
   // Monitor eligibility changes
   event EligibilityUpdated(
       address indexed user,
       bool eligible
   );
   ```

### Emergency Procedures

In case of emergency:

1. **Stop Distributions**
   ```solidity
   function emergencyStop() external onlyOwner {
       _paused = true;
       emit EmergencyStop(block.timestamp);
   }
   ```

2. **Secure Funds**
   ```solidity
   function emergencyWithdraw() external onlyOwner {
       require(_paused, "Not paused");
       payable(owner()).transfer(address(this).balance);
   }
   ```

3. **Recovery**
   ```solidity
   function resume() external onlyOwner {
       _paused = false;
       emit Resumed(block.timestamp);
   }
   ```

## Bug Bounty Program

We maintain a bug bounty program for our smart contracts. Valid vulnerabilities will be rewarded based on severity:

- Critical: Up to 10 ETH
- High: Up to 5 ETH
- Medium: Up to 2 ETH
- Low: Up to 0.5 ETH

### Scope

In scope:
- All smart contracts in `/src`
- Integration patterns
- Math calculations

Out of scope:
- Frontend applications
- Already reported issues
- Issues in dependencies

## Security Audit Status

The current version has undergone the following security measures:

- Internal audit completed: ✅
- External audit completed: ✅
- Formal verification: In progress
- Bug bounty program: Active

Latest audit report: [Link to Audit Report]