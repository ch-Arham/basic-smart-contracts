// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import './ERC721Token.sol';

contract BasicTokenFarm{
    string public name = "Dapp Token Farm";
    address public owner;
    ERC721Token public dappToken;

    // Array to keep track of all the addresses that have ever staked (as we have to issue them rewards later)
    address[] public stakers;

    // How much each investor is staking
    mapping (address => uint) public stakingBalance;
    
    // Investor has staked
    mapping (address => bool) public hasStaked;

    // Current Staking status
    mapping (address => bool) public isStaking;

    // reward accumulated
    mapping (address => uint) public rewardAccumulated;

    constructor(ERC721Token _dappToken)  {
        dappToken = _dappToken;
        owner = msg.sender;
    }

    // 1- Stake Tokens - Dai --> Deposit
    function stakeTokens() public payable{
        // Require amount greater then 0
        require(msg.value > 0, "ammount cannot be 0");

        // Add the amount to the staking balance (update it)
        stakingBalance[msg.sender] += msg.value;

        // Add users to stakers array (if they are not already there) / only if they haven't staked before
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            
        }
        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;
    
    }

    // 3- unstake Tokens (withdraw)
    function unstakeTokens() public payable {
        // fetch staking balance
        uint balance = stakingBalance[msg.sender];

        // Require amount cannot be greater then 0
        require(balance > 0, "staking balance cannot be 0");

        // Transer native token back to the investor
        payable(msg.sender).transfer(stakingBalance[msg.sender]);
        
        // Reset Staking balance
        stakingBalance[msg.sender] = 0;

        //update staking status
        isStaking[msg.sender] = false;

    }
    // 2- Issuin Tokens
    function issueTokens() public {
        // We only want owner to be able to issue tokens
        require(msg.sender == owner, 'Caller must be the owner');

        // We loop through stakers array and reward them/ issue token to them
        for(uint i=0; i<stakers.length; i++) {
            address recepient = stakers[i];
            uint balance = stakingBalance[recepient];
            // we will transfer dapp token equal to the amount of dai they stake
            if(balance > 0){
                rewardAccumulated[msg.sender] += balance;
                
            }

        }
    }

        function claimTokens() public payable {
            uint reward = rewardAccumulated[msg.sender];
            require(reward > 0, "Reward must be greater than 0");
                dappToken.transfer(msg.sender, reward);
                rewardAccumulated[msg.sender]=0;

            
            
        
        }



}