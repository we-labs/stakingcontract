// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


// @author WG <https://twitter.com/whalegoddess>   

contract Human is ERC20Burnable, Ownable{

    uint256 public EMISSION_RATE = 10 ether;
    uint256 public immutable DEFAULT_START_TIMESTAMP;
    address public nft;

    mapping(uint16 => uint256) emissionsBoost;

    mapping (uint16 => uint256) tokenToLastClaimedPassive;

    constructor() ERC20("Human", "HUMAN") {
        DEFAULT_START_TIMESTAMP = 1648317600;
        nft = 0x582b874Af6A8D0eC283febE1988fb4A67c06e050;
        _mint(msg.sender, 10000 ether);
    }

    function claimPassiveYield(uint16[] memory _tokenIds) public {
        require(block.timestamp > DEFAULT_START_TIMESTAMP, "Too early to claim");
        uint256 rewards = 0;

        for (uint i = 0; i < _tokenIds.length; i++) {
            uint16 tokenId = _tokenIds[i];
            require(ERC721(nft).ownerOf(tokenId) == msg.sender,"You are not the owner of this token");

            rewards += getPassiveRewardsForId(tokenId);
            tokenToLastClaimedPassive[tokenId] = block.timestamp;
        }
        _mint(msg.sender, rewards);
    }


    function getPassiveRewardsForId(uint16 _id) public view returns (uint) {
        return (block.timestamp - (tokenToLastClaimedPassive[_id] == 0 ? DEFAULT_START_TIMESTAMP : tokenToLastClaimedPassive[_id])) * (EMISSION_RATE + emissionsBoost[_id]) / 86400;
    }

    function addTraitBoost(uint16[] memory ids, uint256[] memory boosts) external onlyOwner {
        require(ids.length == boosts.length, "ids and boosts not equal length");
        for(uint i = 0; i < ids.length; i++) {
            emissionsBoost[ids[i]] = boosts[i];
        }
    }

    function setNFTAddress(address _address) external onlyOwner {
        nft = _address;
    }
}