// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    address public manager;
    uint public minimumContribution;
    mapping(address => uint) public contributors;
    uint public contributorsCount; // To get the percentage for voting
    uint public deadline;
    uint public targetAmount;
    uint public raisedAmount;

    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete; // to check if the request has been completed
        uint approvalCount; // no of voters who voted yes
        mapping(address => bool) approvals;
    }

    mapping(uint => Request) public requests;
    uint public requestsCount; // act as the index for the requests
    
    constructor(uint _targetAmount, uint _deadline, uint _minimumContribution) {
        manager = msg.sender;
        targetAmount = _targetAmount;
        deadline = block.timestamp + _deadline;
        minimumContribution = _minimumContribution;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    modifier campaignActive() {
        require(block.timestamp < deadline, "Campaign is over");
        _;
    }

    modifier campaignEnded() {
        require(block.timestamp >= deadline, "Campaign is still active");
        _;
    }

    function contribute() external payable campaignActive {
        require(msg.value >= minimumContribution, "Minimum contribution not met");
        if(contributors[msg.sender] == 0) {
            contributorsCount++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getRefund() external payable campaignEnded {
        require(contributors[msg.sender] > 0, "You have not contributed");
        require(raisedAmount < targetAmount, "Target amount has been reached");
        uint amountToRefund = contributors[msg.sender];
        contributors[msg.sender] = 0;
        payable(msg.sender).transfer(amountToRefund);
    }

    function getContractBalance() external view onlyManager returns(uint) {
        return address(this).balance;
    }

    function createRequest(string memory _description, uint _value, address payable _recipient) external onlyManager {
        Request storage newRequest = requests[requestsCount];
        newRequest.description = _description;
        newRequest.value = _value;
        newRequest.recipient = _recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
        requestsCount++;
    }

    function approveRequest(uint _requestId) external campaignEnded {
        Request storage request = requests[_requestId];
        require(contributors[msg.sender] > 0, "You have not contributed");
        require(!request.approvals[msg.sender], "You have already voted");
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint _requestId) external payable onlyManager campaignEnded {
        Request storage request = requests[_requestId];
        require(raisedAmount >= targetAmount, "Target amount has not been reached");
        require(request.approvalCount > (contributorsCount / 2), "More than 50% of contributors must approve");
        require(!request.complete, "Request has already been completed");
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() external view returns(uint, uint, uint, uint, uint, uint) {
        return (
            minimumContribution,
            address(this).balance,
            targetAmount,
            raisedAmount,
            deadline,
            contributorsCount
        );
    }

}