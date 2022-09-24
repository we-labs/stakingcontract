// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "erc721a/contracts/ERC721A.sol";

// @author <https://welabs.io>   

// ░██╗░░░░░░░██╗███████╗██╗░░░░░░█████╗░██████╗░░██████╗░░░██╗░█████╗░
// ░██║░░██╗░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗██╔════╝░░░██║██╔══██╗
// ░╚██╗████╗██╔╝█████╗░░██║░░░░░███████║██████╦╝╚█████╗░░░░██║██║░░██║
// ░░████╔═████║░██╔══╝░░██║░░░░░██╔══██║██╔══██╗░╚═══██╗░░░██║██║░░██║
// ░░╚██╔╝░╚██╔╝░███████╗███████╗██║░░██║██████╦╝██████╔╝██╗██║╚█████╔╝
// ░░░╚═╝░░░╚═╝░░╚══════╝╚══════╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚═╝╚═╝░╚════╝░

contract StakingSkull is Ownable, ReentrancyGuard{
    uint randNonce = 0;
    uint randNonce1 = 1;
    uint256 lockingPeriod = 1;
    uint256 landSupply = 1000;
    uint256 juniorSupply = 1000;
    uint256 public raidPrice = 300 ether;
    uint256 public upgradePrice = 800 ether;
    ERC20Burnable public immutable tokenContract;
    ERC721A public immutable landContract;
    ERC721Burnable public juniorContract;

    constructor(ERC721A _landContract, ERC20Burnable _tokenContract) {
        landContract = _landContract;
        tokenContract = _tokenContract;
    }

    struct StakedToken {
        address staker;
        uint256 tokenId;
        uint256 timeOfLastStake;
    }

    // Staker Info
    struct Staker {
        // uint256 amountStaked;
        StakedToken[] stakedLands;
        StakedToken[] stakedJuniors;
        uint256 unclaimedRewards;
    }

    // Mapping of user address to staker info
    mapping(address => Staker) public stakers;

    // Mapping token Id to staker
    mapping(uint256 => address) public landAddress;
    mapping(uint256 => address) public juniorAddress;

    // Mapping token Id to staker
    mapping(uint256 => uint256) public landResistance;

    event RaidToken(address indexed _from, uint256 tokenId);
    event RaidSucces(address indexed _from, bool _success);
    event RaidJunior(address indexed _from, bool destroyed);

    function setJuniorContract(ERC721Burnable _juniorContract) public onlyOwner {
        juniorContract = _juniorContract;
    }
    function setLockingPeriod(uint256 _lockingPeriod) public onlyOwner {
        lockingPeriod = _lockingPeriod;
    }
    function setLandSupply(uint256 _landSupply) public onlyOwner {
        landSupply = _landSupply;
    }
    function setJuniorSupply(uint256 _juniorSupply) public onlyOwner {
        juniorSupply = _juniorSupply;
    }
    function setUpgradePrice(uint256 _upgradePrice) public onlyOwner {
        upgradePrice = _upgradePrice;
    }
    function setRaidPrice(uint256 _raidPrice) public onlyOwner {
        raidPrice = _raidPrice;
    } 

    // Staking Lands
    function stakeLand(uint256 _tokenId) external {
        require(landContract.ownerOf(_tokenId) == msg.sender,"You don't own this token!");
        landContract.transferFrom(msg.sender, address(this), _tokenId);
        stakers[msg.sender].stakedLands.push(StakedToken(msg.sender, _tokenId, block.timestamp));
        landAddress[_tokenId] = msg.sender;
    }
    function stakeAllLand(uint256[] calldata _tokensIds) external {
        for (uint256 i = 0; i < _tokensIds.length; i++) {
            require(landContract.ownerOf(_tokensIds[i]) == msg.sender,"You don't own this token!");
            landContract.transferFrom(msg.sender, address(this), _tokensIds[i]);
            stakers[msg.sender].stakedLands.push(StakedToken(msg.sender, _tokensIds[i], block.timestamp));
            landAddress[_tokensIds[i]] = msg.sender;
        }
    }
    function unstakeLand(uint256 _tokenId) external {
        require(landAddress[_tokenId] == msg.sender, "You don't own this token!");
        uint256 index = 0;
        for (uint256 i = 0; i < stakers[msg.sender].stakedLands.length; i++) {
            if (stakers[msg.sender].stakedLands[i].tokenId == _tokenId) {
                index = i;
                break;
            }
        }
        require(block.timestamp - stakers[msg.sender].stakedLands[index].timeOfLastStake > lockingPeriod, "You should wait a day to unstake your land");
        // delete stakers[msg.sender].stakedLands[index];
        stakers[msg.sender].stakedLands[index] = stakers[msg.sender].stakedLands[stakers[msg.sender].stakedLands.length-1];
        stakers[msg.sender].stakedLands.pop();
        delete landAddress[_tokenId];
        landContract.transferFrom(address(this), msg.sender, _tokenId);
    }
    function unstakeAllLand(uint256[] calldata _tokensIds) external {
        for (uint256 j = 0; j < _tokensIds.length; j++) {
            require(landAddress[_tokensIds[j]] == msg.sender, "You don't own this token!");
            uint256 index = 0;
            for (uint256 i = 0; i < stakers[msg.sender].stakedLands.length; i++) {
                if (stakers[msg.sender].stakedLands[i].tokenId == _tokensIds[j]) {
                    index = i;
                    break;
                }
            }
            require(block.timestamp - stakers[msg.sender].stakedLands[index].timeOfLastStake > lockingPeriod, "You should wait a day to unstake your land");
            // delete stakers[msg.sender].stakedLands[index];
            stakers[msg.sender].stakedLands[index] = stakers[msg.sender].stakedLands[stakers[msg.sender].stakedLands.length-1];
            stakers[msg.sender].stakedLands.pop();
            delete landAddress[_tokensIds[j]];
            landContract.transferFrom(address(this), msg.sender, _tokensIds[j]);
        }
    }
    function transferLand(uint256 _tokenId, address _recipient) external {
        require(landAddress[_tokenId] == msg.sender, "You don't own this token!");
        uint256 index = 0;
        for (uint256 i = 0; i < stakers[msg.sender].stakedLands.length; i++) {
            if (stakers[msg.sender].stakedLands[i].tokenId == _tokenId) {
                index = i;
                break;
            }
        }
        require(block.timestamp - stakers[msg.sender].stakedLands[index].timeOfLastStake > lockingPeriod, "You should wait a day to transfer your land");
        stakers[msg.sender].stakedLands[index] = stakers[msg.sender].stakedLands[stakers[msg.sender].stakedLands.length-1];
        stakers[msg.sender].stakedLands.pop();

        stakers[_recipient].stakedLands.push(StakedToken(_recipient, _tokenId, block.timestamp));
        landAddress[_tokenId] = _recipient;
    }
    function bulkTransferLand(uint256[] calldata _tokenIds, address[] calldata _recipients) external {
        for(uint256 j = 0; j < _tokenIds.length; j++) {
        require(landAddress[_tokenIds[j]] == msg.sender, "You don't own this token!");
        uint256 index = 0;
        for (uint256 i = 0; i < stakers[msg.sender].stakedLands.length; i++) {
            if (stakers[msg.sender].stakedLands[i].tokenId == _tokenIds[j]) {
                index = i;
                break;
            }
        }
        require(block.timestamp - stakers[msg.sender].stakedLands[index].timeOfLastStake > lockingPeriod, "You should wait a day to unstake your land");
        stakers[msg.sender].stakedLands[index] = stakers[msg.sender].stakedLands[stakers[msg.sender].stakedLands.length-1];
        stakers[msg.sender].stakedLands.pop();

        stakers[_recipients[j]].stakedLands.push(StakedToken(_recipients[j], _tokenIds[j], block.timestamp));
        landAddress[_tokenIds[j]] = _recipients[j];
        }
    }

    // Staking Juniors
    function stakeJunior(uint256 _tokenId) external {
        require(juniorContract.ownerOf(_tokenId) == msg.sender,"You don't own this token!");
        juniorContract.transferFrom(msg.sender, address(this), _tokenId);
        stakers[msg.sender].stakedJuniors.push(StakedToken(msg.sender, _tokenId, block.timestamp));
        juniorAddress[_tokenId] = msg.sender;
    }
    function stakeAllJunior(uint256[] calldata _tokensIds) external {
        for (uint256 i = 0; i < _tokensIds.length; i++) {
            require(juniorContract.ownerOf(_tokensIds[i]) == msg.sender,"You don't own this token!");
            juniorContract.transferFrom(msg.sender, address(this), _tokensIds[i]);
            stakers[msg.sender].stakedJuniors.push(StakedToken(msg.sender, _tokensIds[i], block.timestamp));
            juniorAddress[_tokensIds[i]] = msg.sender;
        }
    }
    function unstakeJunior(uint256 _tokenId) external {
        require(juniorAddress[_tokenId] == msg.sender, "You don't own this token!");
        uint256 index = 0;
        for (uint256 i = 0; i < stakers[msg.sender].stakedJuniors.length; i++) {
            if (stakers[msg.sender].stakedJuniors[i].tokenId == _tokenId) {
                index = i;
                break;
            }
        }
        stakers[msg.sender].stakedJuniors[index] = stakers[msg.sender].stakedJuniors[stakers[msg.sender].stakedJuniors.length-1];
        stakers[msg.sender].stakedJuniors.pop();
        delete juniorAddress[_tokenId];
        juniorContract.transferFrom(address(this), msg.sender, _tokenId);
    }
    function unstakeAllJunior(uint256[] calldata _tokensIds) external {
        for (uint256 j = 0; j < _tokensIds.length; j++) {
            require(juniorAddress[_tokensIds[j]] == msg.sender, "You don't own this token!");
            uint256 index = 0;
            for (uint256 i = 0; i < stakers[msg.sender].stakedJuniors.length; i++) {
                if (stakers[msg.sender].stakedJuniors[i].tokenId == _tokensIds[j]) {
                    index = i;
                    break;
                }
            }
            stakers[msg.sender].stakedJuniors[index] = stakers[msg.sender].stakedJuniors[stakers[msg.sender].stakedJuniors.length-1];
            stakers[msg.sender].stakedJuniors.pop();
            delete juniorAddress[_tokensIds[j]];
            juniorContract.transferFrom(address(this), msg.sender, _tokensIds[j]);
        }
    }

    // Raiding
    function raid(uint256[] calldata _juniorIds) public payable {
        // Find the index of this token id in the stakedLands array
        require(_juniorIds.length <= 5, "You can raid with a maximum of 5 Junior Kongz");
        // Check junior kongz ownership
        for (uint256 i = 0; i < _juniorIds.length; i++) {
            require(juniorAddress[_juniorIds[i]] == msg.sender, "You must own the Junior Kong");
        }
        // Find random land token ID
        uint counter = 1;
        uint256 randToken;
        do {
            randToken = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, counter))) % landSupply;
            counter++;
        } while(landAddress[randToken] == address(0) || landAddress[randToken] == msg.sender) ;
        emit RaidToken(msg.sender, randToken);

        if ( randomRaid() > (90 + landResistance[randToken] - _juniorIds.length)) {
            ERC20Burnable(tokenContract).burnFrom(msg.sender, raidPrice);
            emit RaidSucces(msg.sender, true);
            // Unstake
            uint256 indexLand = 0;
            for (uint256 i = 0; i < stakers[landAddress[randToken]].stakedLands.length; i++) {
                if (stakers[landAddress[randToken]].stakedLands[i].tokenId == randToken) {
                    indexLand = i;
                    break;
                }
            }
            stakers[landAddress[randToken]].stakedLands[indexLand] = stakers[landAddress[randToken]].stakedLands[stakers[landAddress[randToken]].stakedLands.length-1];
            stakers[landAddress[randToken]].stakedLands.pop();
            delete landAddress[randToken];
            // Stake
            stakers[msg.sender].stakedLands.push(StakedToken(msg.sender, randToken, block.timestamp));
            landAddress[randToken] = msg.sender;
            // Burn Junior
            if (_juniorIds.length > 0 && randomBurn() > 90 ) {
                uint256 indexJunior = 0;
                for (uint256 i = 0; i < stakers[msg.sender].stakedJuniors.length; i++) {
                    if (stakers[msg.sender].stakedJuniors[i].tokenId == _juniorIds[0]) {
                        indexJunior = i;
                        break;
                    }
                }
                ERC721Burnable(juniorContract).burn(_juniorIds[0]);
                stakers[msg.sender].stakedJuniors[indexJunior] = stakers[msg.sender].stakedJuniors[stakers[msg.sender].stakedJuniors.length-1];
                stakers[msg.sender].stakedJuniors.pop();
                delete juniorAddress[_juniorIds[0]];
                emit RaidJunior(msg.sender, true);
            }
        } else {
            ERC20Burnable(tokenContract).transferFrom(msg.sender, address(this), raidPrice);
            stakers[landAddress[randToken]].unclaimedRewards += raidPrice;
            emit RaidSucces(msg.sender, false);
        }
    }

    function randomRaid() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randNonce))) % 100;
    }
    function randomBurn() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randNonce1))) % 100;
    }

    function upgradeLand(uint16 _tokenId) public {
        require(landAddress[_tokenId] == msg.sender,"This item is not staked by you!");
        require(landResistance[_tokenId] < 5,"You've already reached maximum upgrades");
        ERC20Burnable(tokenContract).burnFrom(msg.sender, upgradePrice);
        landResistance[_tokenId] ++;
    }

    function getStakedLands(address _user) public view returns (StakedToken[] memory) {
        if (stakers[_user].stakedLands.length > 0) {
            StakedToken[] memory _stakedLands = new StakedToken[](stakers[_user].stakedLands.length);
            uint256 _index = 0;
            for (uint256 j = 0; j < stakers[_user].stakedLands.length; j++) {
                if (stakers[_user].stakedLands[j].staker != (address(0))) {
                    _stakedLands[_index] = stakers[_user].stakedLands[j];
                    _index++;
                }
            }
            return _stakedLands;
        }
        else {
            return new StakedToken[](0);
        }
    }
    function getStakedJuniors(address _user) public view returns (StakedToken[] memory) {
        if (stakers[_user].stakedJuniors.length > 0) {
            StakedToken[] memory _stakedJuniors = new StakedToken[](stakers[_user].stakedJuniors.length);
            uint256 _index = 0;
            for (uint256 j = 0; j < stakers[_user].stakedJuniors.length; j++) {
                if (stakers[_user].stakedJuniors[j].staker != (address(0))) {
                    _stakedJuniors[_index] = stakers[_user].stakedJuniors[j];
                    _index++;
                }
            }
            return _stakedJuniors;
        }
        else {
            return new StakedToken[](0);
        }
    }

    // Unstake all
    function unstakeAll() public onlyOwner {
        for (uint256 _tokenId = 0; _tokenId < landSupply; _tokenId++) {
            require(landAddress[_tokenId] == msg.sender, "You don't own this token!");
            // uint256 index = 0;
            for (uint256 _index = 0; _index < stakers[msg.sender].stakedLands.length; _index++) {
                stakers[landAddress[_tokenId]].stakedLands[_index] = stakers[landAddress[_tokenId]].stakedLands[stakers[landAddress[_tokenId]].stakedLands.length-1];
                stakers[landAddress[_tokenId]].stakedLands.pop();
                delete landAddress[_tokenId];
                landContract.transferFrom(address(this), landAddress[_tokenId], _tokenId);
            }
        }

        // Unstake Juniors
        for (uint256 _tokenId = 0; _tokenId < juniorSupply; _tokenId++) {
            require(juniorAddress[_tokenId] == msg.sender, "You don't own this token!");
            for (uint256 _index = 0; _index < stakers[msg.sender].stakedJuniors.length; _index++) {
                stakers[juniorAddress[_tokenId]].stakedJuniors[_index] = stakers[juniorAddress[_tokenId]].stakedJuniors[stakers[juniorAddress[_tokenId]].stakedJuniors.length-1];
                stakers[juniorAddress[_tokenId]].stakedJuniors.pop();
                delete juniorAddress[_tokenId];
                landContract.transferFrom(address(this), juniorAddress[_tokenId], _tokenId);
            }
        }
    }
    // Rewards
    function claimRewards() external {
        uint256 rewards = stakers[msg.sender].unclaimedRewards;
        require(rewards > 0, "You have no rewards to claim");
        stakers[msg.sender].unclaimedRewards = 0;
        tokenContract.transfer(msg.sender, rewards);
    }

    function availableRewards(address _staker) public view returns (uint256) {
        uint256 rewards = stakers[_staker].unclaimedRewards;
        return rewards;
    }

}