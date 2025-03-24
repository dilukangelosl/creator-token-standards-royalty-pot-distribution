// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "./mocks/MockERC721C.sol";
import "./mocks/TestableRoyaltyPotDistribution.sol";
import "../src/programmable-royalties/distribution/eligibility/implementations/NFTHolderEligibilityCheck.sol";

contract RoyaltyPotDistributionTest is Test {
    TestableRoyaltyPotDistribution public distribution;
    NFTHolderEligibilityCheck public eligibilityCheck;
    MockERC721C public nft;
    MockERC721C public eligibilityNft;
    
    address public admin = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    address public user3 = address(4);
    
    uint256 public constant DISTRIBUTION_PERIOD = 30 days;
    uint256 public constant MIN_NFT_REQUIRED = 1;

    event DistributionStarted(uint256 indexed distributionId, uint256 startTime, uint256 endTime);
    event DistributionClaimed(address indexed user, uint256 indexed distributionId, uint256 amount);

    function setUp() public {
        vm.startPrank(admin);
        
        // Deploy contracts
        nft = new MockERC721C();
        eligibilityNft = new MockERC721C();
        distribution = new TestableRoyaltyPotDistribution(
            address(nft),
            DISTRIBUTION_PERIOD
        );
        eligibilityCheck = new NFTHolderEligibilityCheck(MIN_NFT_REQUIRED);
        
        // Setup eligibility
        eligibilityCheck.addEligibleCollection(address(eligibilityNft));
        distribution.setEligibilityImplementation(address(eligibilityCheck));
        
        vm.stopPrank();
    }

    function testDistributionClaim() public {
        // Setup
        vm.startPrank(admin);
        nft.mint(user1);  // User1 gets NFT token 1
        nft.mint(user2);  // User2 gets NFT token 2
        eligibilityNft.mint(user1);  // Make user1 eligible
        
        uint256 distributionId = distribution.startNewDistribution();
        
        // Update distribution with 2 ETH
        vm.deal(address(distribution), 2 ether);
        distribution.exposed_updateDistribution(2 ether);
        
        // Fast forward past distribution period
        vm.warp(block.timestamp + DISTRIBUTION_PERIOD + 1);
        vm.stopPrank();
        
        // User1 claims their share
        vm.startPrank(user1);
        uint256 balanceBefore = user1.balance;
        distribution.claimDistribution(distributionId);
        uint256 balanceAfter = user1.balance;
        
        // Should receive 1 ETH (half of total as there are 2 NFTs)
        assertEq(balanceAfter - balanceBefore, 1 ether);
        
        vm.stopPrank();
    }

    function testMultipleDistributionPeriods() public {
        vm.startPrank(admin);
        
        // Setup initial state
        nft.mint(user1);  // User1 gets NFT token 1
        eligibilityNft.mint(user1);  // Make user1 eligible
        
        // First distribution period
        uint256 distributionId1 = distribution.startNewDistribution();
        vm.deal(address(distribution), 1 ether);
        distribution.exposed_updateDistribution(1 ether);
        vm.warp(block.timestamp + DISTRIBUTION_PERIOD + 1);
        
        // Second distribution period
        uint256 distributionId2 = distribution.startNewDistribution();
        vm.deal(address(distribution), 3 ether); // Update balance to cover both claims
        distribution.exposed_updateDistribution(2 ether);
        vm.warp(block.timestamp + DISTRIBUTION_PERIOD + 1);
        
        vm.stopPrank();
        
        // User1 claims from both periods
        vm.startPrank(user1);
        uint256 balanceBefore = user1.balance;
        
        distribution.claimDistribution(distributionId1);
        distribution.claimDistribution(distributionId2);
        
        uint256 balanceAfter = user1.balance;
        
        // Should receive total 3 ETH (1 from first period + 2 from second period)
        assertEq(balanceAfter - balanceBefore, 3 ether);
        
        vm.stopPrank();
    }

    function testEligibilityCheck() public {
        vm.startPrank(admin);
        
        // Initially no one is eligible as they don't hold eligibilityNft
        assertFalse(distribution.checkEligibility(user1));
        assertFalse(distribution.checkEligibility(user2));
        
        // Make user1 eligible by giving them eligibilityNft
        eligibilityNft.mint(user1);
        assertTrue(distribution.checkEligibility(user1));
        assertFalse(distribution.checkEligibility(user2));
        
        vm.stopPrank();
    }

    function testDynamicEligibilityChanges() public {
        vm.startPrank(admin);
        nft.mint(user1);
        
        uint256 distributionId = distribution.startNewDistribution();
        vm.deal(address(distribution), 1 ether);
        distribution.exposed_updateDistribution(1 ether);
        
        // Initially user1 is not eligible
        assertFalse(distribution.checkEligibility(user1));
        
        // Make user1 eligible
        eligibilityNft.mint(user1);
        assertTrue(distribution.checkEligibility(user1));
        
        vm.warp(block.timestamp + DISTRIBUTION_PERIOD + 1);
        vm.stopPrank();
        
        // User1 should now be able to claim
        vm.startPrank(user1);
        uint256 balanceBefore = user1.balance;
        distribution.claimDistribution(distributionId);
        uint256 balanceAfter = user1.balance;
        assertEq(balanceAfter - balanceBefore, 1 ether);
        vm.stopPrank();
    }

    function testStartDistribution() public {
        vm.startPrank(admin);
        
        uint256 distributionId = distribution.startNewDistribution();
        assertEq(distributionId, 1);
        
        IRoyaltyPotDistribution.Distribution memory dist = distribution.getDistributionInfo(1);
        assertEq(dist.id, 1);
        assertTrue(dist.startTime > 0);
        assertEq(dist.endTime, dist.startTime + DISTRIBUTION_PERIOD);
        assertEq(dist.totalAmount, 0);
        assertEq(dist.totalEligibleTokens, 0);
        assertFalse(dist.claimed);
        
        vm.stopPrank();
    }

    receive() external payable {}
}