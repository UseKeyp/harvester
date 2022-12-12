pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract harvest {
  // Mapping from user address to a nft address to a list of token ids
  mapping(address => mapping(address =>  mapping(uint256 => bool))) public userTokens;
 
  

  // Address of the contract owner
  address private owner;

  constructor(address _owner) {
    // Set the owner of the contract
    owner = _owner;
  }

  function sell(address tokenAddress, uint256 tokenId) external {
    // Ensure that the caller is the owner of the token
    ERC721 token = ERC721(tokenAddress);
    require(msg.sender == token.ownerOf(tokenId), "Only the owner can sell this token");

    // Transfer the token to the contract using the receiver pattern
    token.safeTransferFrom(msg.sender, address(this), tokenId);

    // Add the token to the user's array of sold tokens
    userTokens[msg.sender][tokenAddress][tokenId] = true;

    // Send 1 wei to the seller as payment
    (bool success, ) = msg.sender.call{value: 1}("");
    require(success, "Failed to send eth.");

  }

  function buy(address tokenAddress, uint256 tokenId) external payable {
    // Check that it's after January 1, 2023
    require(block.timestamp >= 1640995200, "You can only buy back your tokens after January 1, 2023");

    // Check that the caller is the owner of the token
    require(userTokens[msg.sender][tokenAddress][tokenId], "You don't own this token");

    // Transfer the token from the contract to the caller
    ERC721(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId);

    // Remove the token from the user's array of sold tokens
    userTokens[msg.sender][tokenAddress][tokenId] = false;

    // Charge 0.0001 ether for the buyback
    require(msg.value == 1000000000, "You must pay 0.001 ether to buy back your token");
  }

  function cashout() public {
    // Only the owner of the contract can call this function
    require(msg.sender == owner, "Only the owner can cash out");

    // Transfer all the ETH on the contract to the owner
    (bool success, ) = owner.call{value: address(this).balance}("");
    require(success, "Failed to send eth.");
  }
}
