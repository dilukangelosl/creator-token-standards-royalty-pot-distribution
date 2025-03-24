// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../src/programmable-royalties/distribution/eligibility/implementations/NFTHolderEligibilityCheck.sol";

contract MockEligibilityNFT is ERC721 {
    uint256 private _currentTokenId;

    constructor() ERC721("MockEligibilityNFT", "MENFT") {}

    function mint(address to) external returns (uint256) {
        _currentTokenId++;
        _mint(to, _currentTokenId);
        return _currentTokenId;
    }
}

contract NFTHolderEligibilityCheckTest is Test {
    NFTHolderEligibilityCheck public eligibilityCheck;
    MockEligibilityNFT public nft1;
    MockEligibilityNFT public nft2;
    
    address public admin = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    uint256 public constant MIN_REQUIRED_BALANCE = 2;

    function setUp() public {
        vm.startPrank(admin);
        
        nft1 = new MockEligibilityNFT();
        nft2 = new MockEligibilityNFT();
        eligibilityCheck = new NFTHolderEligibilityCheck(MIN_REQUIRED_BALANCE);
        
        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(eligibilityCheck.getMinRequiredBalance(), MIN_REQUIRED_BALANCE);
        assertEq(eligibilityCheck.getEligibleCollections().length, 0);
    }

    function testAddCollection() public {
        vm.startPrank(admin);
        
        eligibilityCheck.addEligibleCollection(address(nft1));
        IERC721[] memory collections = eligibilityCheck.getEligibleCollections();
        
        assertEq(collections.length, 1);
        assertEq(address(collections[0]), address(nft1));
        
        vm.stopPrank();
    }

    function testRemoveCollection() public {
        vm.startPrank(admin);
        
        eligibilityCheck.addEligibleCollection(address(nft1));
        eligibilityCheck.addEligibleCollection(address(nft2));
        eligibilityCheck.removeEligibleCollection(address(nft1));
        
        IERC721[] memory collections = eligibilityCheck.getEligibleCollections();
        assertEq(collections.length, 1);
        assertEq(address(collections[0]), address(nft2));
        
        vm.stopPrank();
    }

    function testEligibilityCheck() public {
        vm.startPrank(admin);
        eligibilityCheck.addEligibleCollection(address(nft1));
        eligibilityCheck.addEligibleCollection(address(nft2));
        
        // User1 gets 1 NFT from each collection (total 2)
        nft1.mint(user1);
        nft2.mint(user1);
        
        // User2 gets 1 NFT from nft1 (total 1)
        nft1.mint(user2);
        
        vm.stopPrank();

        // User1 should be eligible (has 2 NFTs total)
        assertTrue(eligibilityCheck.isEligible(user1));
        
        // User2 should not be eligible (has only 1 NFT)
        assertFalse(eligibilityCheck.isEligible(user2));
    }

    function testUpdateMinBalance() public {
        vm.startPrank(admin);
        
        uint256 newMinBalance = 3;
        eligibilityCheck.setMinRequiredBalance(newMinBalance);
        assertEq(eligibilityCheck.getMinRequiredBalance(), newMinBalance);
        
        vm.stopPrank();
    }

    function testFailAddCollectionNonOwner() public {
        vm.prank(user1);
        eligibilityCheck.addEligibleCollection(address(nft1));
    }

    function testFailRemoveCollectionNonOwner() public {
        vm.startPrank(admin);
        eligibilityCheck.addEligibleCollection(address(nft1));
        vm.stopPrank();

        vm.prank(user1);
        eligibilityCheck.removeEligibleCollection(address(nft1));
    }

    function testFailUpdateMinBalanceNonOwner() public {
        vm.prank(user1);
        eligibilityCheck.setMinRequiredBalance(3);
    }

    function testFailAddZeroAddress() public {
        vm.prank(admin);
        eligibilityCheck.addEligibleCollection(address(0));
    }

    function testFailRemoveNonExistentCollection() public {
        vm.prank(admin);
        eligibilityCheck.removeEligibleCollection(address(nft1));
    }
}