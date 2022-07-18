// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract NewJackpot {
    uint public jackpot;
    uint public startHourTime;
    uint public endHourTime;
    address payable public lastBuyer;
    mapping (address => uint) buyers; // For Histiry
    address payable public bigBuyer;
    uint public bigBuyAmount;
    uint public bigBuyTime; // 00:00 UTC Start and End

    constructor () payable {
        jackpot = msg.value;
        startHourTime = block.timestamp;
        endHourTime = startHourTime + 1 hours;
        bigBuyAmount = 0;
    }

    // Function triggered when user buy token
    function userBuy(address payable _buyer, uint _amount) public {
        jackpot += _amount;
        buyers[_buyer] = _amount;
        startHourTime = block.timestamp;
        endHourTime = startHourTime + 1 hours;
        lastBuyer = _buyer;
        if(_amount >= bigBuyAmount) {
            bigBuyAmount = _amount;
            bigBuyer = _buyer;
        }
        if(jackpot >= 10000) {
            maxAccumulated();
        }
    }

    //Function Triggered if jackpot>=100k
    function maxAccumulated() public {
        //Function to buy Main Token for 50% of Jackpot
        buyMainToken();

        //Function to send 5% to the bigBuyer
        sendFivePercent1();
    }

    //Function to send 5% to the bigBuyer if jackpot>=100k
    function sendFivePercent1() public payable {
        // bigBuyer.transfer(500/10000*address(this).balance);
        bigBuyer.transfer(bigBuyAmount/10000*address(this).balance);
        bigBuyer= payable(address(0));
        bigBuyAmount = 0;
    }

    // function to buy main token for 50% of the jackpot if jackpot >= 100k
    function buyMainToken() public {}

    // function triggers whenn 1 hour has passed since last buy
    function oneHourPassed() public payable {
        // lastBuyer.transfer((50/100) * jackpot);
        lastBuyer.transfer(bigBuyAmount/100 * address(this).balance);
        lastBuyer = payable(address(0));
    }

    // function triggers when the time is 00:00 UTC
    function sendFivePercent2() public payable {
        require(bigBuyer != address(0),"No Current Big Buyer");
        // bigBuyer.transfer((5/100)*jackpot);
        bigBuyer.transfer(bigBuyAmount/100 * address(this).balance);
        bigBuyer = payable(address(0));
        bigBuyAmount = 0;
        // increment 1 day to bigBuyTime
    }
}

// Chain link keepers not integrated yet