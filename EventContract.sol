// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EventContract {
    struct Event {
        address payable organizer;
        string name;
        uint date;
        uint ticketCount;
        uint ticketRemaining;
        uint ticketPrice;
    }

    mapping (address => uint) private totalAmounts;
    mapping (uint => Event) public events;
    mapping(address => mapping(uint => uint)) private tickets; // address => (eventId => ticketCount)

    uint private eventId;

    modifier eventStartDate(uint _date) {
        require(_date > block.timestamp, "Event date must be in the future");
        _;
    }
    
    modifier ticketAvailability(uint _ticketCount) {
        require(_ticketCount > 0, "Ticket count must be greater than 0");
        _;
    } 


    function createEvent(string memory _name, uint _date, uint _ticketCount, uint ticketPrice) external eventStartDate(_date) ticketAvailability(_ticketCount) {
        events[eventId] = Event(payable(msg.sender), _name, _date, _ticketCount, _ticketCount, ticketPrice);
        eventId++;
    }

    function buyTicket(uint _eventId, uint _ticketQuantity) external payable {
        Event storage _event = events[_eventId];
        require(_event.date != 0, "Event does not exist");
        require(_event.date > block.timestamp, "Event has already started");
        require(_event.ticketRemaining >= _ticketQuantity, "Not enough tickets available");
        require(msg.value == _event.ticketPrice * _ticketQuantity, "Incorrect amount of Ether sent");

        _event.ticketRemaining -= _ticketQuantity;
        tickets[msg.sender][_eventId] += _ticketQuantity;
        totalAmounts[_event.organizer] += msg.value;
    }

    function transferTicket(uint _eventId, uint _ticketQuantity, address to) external {
        require(events[_eventId].date != 0, "Event does not exist");
        require(events[_eventId].date > block.timestamp, "Event has already occured");
        require(tickets[msg.sender][_eventId] >= _ticketQuantity,"You do not have enough tickets");
        require(to != msg.sender, "You cannot transfer tickets to yourself");

        tickets[msg.sender][_eventId] -= _ticketQuantity;
        tickets[to][_eventId] += _ticketQuantity;

    }

    function getRefund(uint _eventId) external {
        Event storage _event = events[_eventId];
        require(_event.date != 0, "Event does not exist");
        require(_event.date > block.timestamp, "Date to refund has expired.");
        require(_event.ticketRemaining < _event.ticketCount, "No tickets were bought");

        uint _ticketQuantity = tickets[msg.sender][_eventId];
        require(_ticketQuantity > 0, "No tickets were bought");

        tickets[msg.sender][_eventId] = 0;
        _event.ticketRemaining += _ticketQuantity;

        payable(msg.sender).transfer(_event.ticketPrice * _ticketQuantity);
    }

    function getTicketCount(uint _eventId) external view returns (uint) {
        return tickets[msg.sender][_eventId];
    }

    function getBalanceOfContract() external view returns (uint) {
        // for now, anyone can see the balance of the contract
        return address(this).balance;
    }

    function getEventBalance(uint _eventId) external view returns (uint) {
        require(events[_eventId].organizer == msg.sender, "Only the organizer can see the balance of the event");
        return totalAmounts[msg.sender];
    }

    function withdraw(uint _eventId) external {
        require(block.timestamp > events[_eventId].date, "Event has not started yet, cannot withdraw funds");
        require(msg.sender == events[_eventId].organizer, "Only the organizer can withdraw funds");
        require(totalAmounts[msg.sender] > 0, "No funds to withdraw");
        events[_eventId].organizer.transfer(totalAmounts[msg.sender]);
    }

    function getEventCount() external view returns (uint) {
        return eventId;
    }
}