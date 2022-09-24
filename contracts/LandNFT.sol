// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LandNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmountPerTx = 5;
    uint256 public cost = 0.01 ether;
    bool public paused = false;
    Counters.Counter private supply;
    IERC20 public tokenAddress;
    uint256 public rate = 100 * 10 ** 18;
    mapping(uint256 => uint256) public landResistance;

    constructor(string memory name, string memory symbol, address _tokenAddress) ERC721(name, symbol) {
        tokenAddress = IERC20(_tokenAddress);
    }

    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");
        require(supply.current() + _mintAmount <= maxSupply, "Max supply exceeded!");
        _;
    }

    function mint(uint256 _mintAmount) public {
        require(!paused, "The contract is paused!");
        // require(msg.value >= cost * _mintAmount, "Insufficient funds!");
        // tokenAddress.transferFrom(msg.sender, address(this), rate);
        _mintLoop(msg.sender, _mintAmount);
    }

    function safeMint() public {
        tokenAddress.transferFrom(msg.sender, address(this), rate);
        supply.increment();
        _safeMint(msg.sender, supply.current());
    }
    
    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            landResistance[supply.current()] == 90;
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }

    function upgrade(uint16 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You're not the owner of this token");
        landResistance[_tokenId] ++;
    }

    function getResistanceById(uint16 _tokenId) public view returns (uint) {
        return landResistance[_tokenId];
    }
}