// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/NTNFT.sol";
import "openzeppelin-contracts/token/ERC721/utils/ERC721Holder.sol";

contract NTNFTTest is Test, ERC721Holder {
    NTNFT public nft;

    function setUp() public {
        nft = new NTNFT();
    }

    function testIncreaseCounter() public {
        nft.mintNft();
        uint tokenCounter = nft.getTokenCounter();
        assertEq(tokenCounter, 1);
    }

    function testTwiceMintError() external {
        nft.mintNft();
        vm.expectRevert(NTNFT__CanOnlyMintOnce.selector);
        nft.mintNft();
    }

    function testHasMinted() public {
        uint tokenId = nft.mintNft();
        address minter = nft.ownerOf(tokenId);
        bool minted = nft.hasMinted(minter);
        assertEq(minted, true);
    }

    function testBurn() public {
        uint tokenId = nft.mintNft();
        address minter = nft.ownerOf(tokenId);
        nft.burn(tokenId);
        bool minted = nft.hasMinted(minter);
        assertEq(minted, false);
    }

    function testBurnWithoutOwning() public {
        vm.prank(address(1));
        uint token = nft.mintNft();
        vm.expectRevert(NTNFT__NotNFTOwner.selector);
        vm.prank(address(2));
        nft.burn(token);
    }

    function testTransfer() public {
        address alice = address(1);
        vm.prank(alice);
        uint tokenId = nft.mintNft();
        address bob = address(2);
        vm.prank(bob);
        vm.expectRevert(NTNFT__NftNotTransferrable.selector);
        nft.transferFrom(alice, bob, tokenId);
    }
}
