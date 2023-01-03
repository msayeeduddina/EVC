// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyToken is ERC20, ERC721Holder, Ownable {

    IERC721 public nft;

    uint256 public EMISSION_RATE = (86400) / 1 days;

    mapping(uint256 => address) public tokenOwnerOf;
    mapping(uint256 => uint256) public tokenStakedAt;

    constructor(address _nft) ERC20("MyToken", "MTK") {
        nft = IERC721(_nft);
    }

    function stake(uint256 tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        tokenOwnerOf[tokenId] = msg.sender;
        tokenStakedAt[tokenId] = block.timestamp;
    }

    function calculateTokens(uint256 tokenId) public view returns(uint256) {
        uint256 timeElapsed = block.timestamp - tokenStakedAt[tokenId];
        if (tokenId < 10) {
            return timeElapsed * EMISSION_RATE;
        } else if (tokenId > 10 && tokenId < 20) {
            return timeElapsed * EMISSION_RATE * 2;
        } else {
            return timeElapsed * EMISSION_RATE * 3;
        }
    }

    function unstake(uint256 tokenId) external {
        require(tokenOwnerOf[tokenId] == msg.sender, "You can't unstake");
        _mint(msg.sender, calculateTokens(tokenId)); // Minting the tokens for staking
        nft.transferFrom(address(this), msg.sender, tokenId);
        delete tokenOwnerOf[tokenId];
        delete tokenStakedAt[tokenId];
    }

}
