// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    address public manager;
    address payable[] public participants; 

    constructor(){
        manager = msg.sender;
    }

    modifier onlyManager(){
        require(msg.sender == manager, "You are not authorized.");
        _;
    }

    modifier priceChecker(){
        require(msg.value == 1 ether, "Amount not accurate.");
        _;
    }

    modifier participantsChecker(){
        require(participants.length >= 3, "Not enough participants yet.");
        _;
    }

    receive() external payable priceChecker{
        participants.push(payable(msg.sender));
    }

    function getBalance() public view onlyManager returns(uint){
        return address(this).balance;
    }

    function randomGeneration() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function selectWinner() public onlyManager participantsChecker returns(address){
        address payable winner = participants[randomGeneration() % participants.length];
        winner.transfer(getBalance());
        participants = new address payable[](0);
        return winner;
    }
}
