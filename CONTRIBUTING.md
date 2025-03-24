# Contributing to ERC721C Royalty Pot Distribution

We appreciate your interest in contributing to the ERC721C Royalty Pot Distribution system! This guide will help you get started.

## Development Setup

1. **Install Dependencies**
```bash
forge install
```

2. **Build**
```bash
forge build
```

3. **Run Tests**
```bash
forge test
```

## Development Workflow

### 1. Branch Naming
- `feature/`: For new features
- `fix/`: For bug fixes
- `docs/`: For documentation updates
- `test/`: For test additions or modifications

Example: `feature/custom-eligibility-checker`

### 2. Commit Messages
Follow conventional commits:
```
feat: add custom eligibility checker
fix: prevent double-claim in edge case
docs: update integration guide
test: add multiple distribution period tests
```

### 3. Testing Requirements
- All new features must include tests
- Maintain 100% line coverage
- Test edge cases thoroughly
- Include integration tests for new features

### 4. Code Style
- Follow Solidity style guide
- Use custom errors instead of revert strings
- Document functions with NatSpec
- Keep functions focused and modular
- Optimize for gas where possible

## Pull Request Process

1. **Before Submitting**
   - Run full test suite
   - Update documentation if needed
   - Add test cases
   - Check gas optimizations

2. **PR Template**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement

## Test Coverage
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Edge cases covered

## Gas Impact
- Added functions gas cost
- Changes to existing function gas costs
```

3. **Review Process**
   - Two approvals required
   - All tests must pass
   - Gas optimizations reviewed
   - Documentation updated

## Contract Structure Guidelines

### 1. New Eligibility Checkers
```solidity
contract NewEligibilityCheck is IEligibilityCheck {
    // Required implementation
    function isEligible(address user) external view returns (bool);
    
    // Optional helper functions
    function validateRequirements() internal view returns (bool);
}
```

### 2. Distribution Extensions
```solidity
contract ExtendedDistribution is RoyaltyPotDistribution {
    // Extend core functionality
    function newFeature() external {
        // Implement new feature
    }
    
    // Override core functions if needed
    function _getEligibleTokenCount(address user, uint256 timestamp)
        internal
        override
        returns (uint256)
    {
        // Custom implementation
    }
}
```

## Gas Optimization Guidelines

1. **Storage**
   - Pack related storage variables
   - Use mappings for sparse data
   - Minimize storage writes

2. **Functions**
   - Use external instead of public when possible
   - Mark view/pure functions appropriately
   - Use unchecked blocks for safe math

3. **Loops**
   - Avoid unbounded loops
   - Cache array lengths
   - Use mapping lookups instead of iteration

## Security Considerations

1. **Access Control**
   - Use proper modifiers
   - Check permissions thoroughly
   - Validate inputs

2. **Reentrancy**
   - Follow checks-effects-interactions pattern
   - Use ReentrancyGuard where needed
   - Be careful with external calls

3. **Edge Cases**
   - Handle zero values
   - Check array bounds
   - Validate timestamps

## Questions and Support

- Open an issue for feature requests
- Join our Discord for discussions
- Check existing issues before creating new ones

## License
By contributing, you agree that your contributions will be licensed under the MIT License.