// SPDX-License-Identifier
pragma solidity ^0.8.17;

contract TicketSale {
    address public manager;
    uint public ticketPrice;
    uint public totalTickets;

    // Maps ticket ID to its owner
    mapping(uint => address) public ticketOwners;

    // Maps an address to the ticket ID they own
    mapping(address => uint) public ownerToTicket;

    // Mapping for swap offers: maps a ticket ID to the address that offered a swap
    mapping(uint => address) public swapOffers;

    // Mapping for resale tickets: maps a ticket ID to its resale price
    mapping(uint => uint) public resaleTickets;

    constructor(uint numTickets, uint price) {
        manager = msg.sender;
        ticketPrice = price;
        totalTickets = numTickets;
    }

    // Buy a ticket with a specified ticket ID
    function buyTicket(uint ticketId) public payable {
        require(ticketId > 0 && ticketId <= totalTickets, "Invalid ticket ID.");
        require(ticketOwners[ticketId] == address(0), "Ticket already sold.");
        require(ownerToTicket[msg.sender] == 0, "You already own a ticket.");
        require(msg.value == ticketPrice, "Incorrect ticket price.");

        ticketOwners[ticketId] = msg.sender;
        ownerToTicket[msg.sender] = ticketId;
    }

    // Get the ticket ID associated with an address
    function getTicketOf(address person) public view returns (uint) {
        return ownerToTicket[person];
    }

    // Offer a ticket swap
    function offerSwap(uint ticketId) public {
        require(ticketOwners[ticketId] == msg.sender, "You do not own this ticket.");
        swapOffers[ticketId] = msg.sender;
    }

    // Accept a swap offer
    function acceptSwap(uint partnerTicketId) public {
        address partner = ticketOwners[partnerTicketId];
        uint senderTicketId = getTicketOf(msg.sender);

        require(senderTicketId != 0, "You don't own a ticket.");
        require(partner != address(0), "Partner does not own a ticket.");
        require(swapOffers[partnerTicketId] == partner, "No swap offer from partner.");

        // Perform the ticket swap
        ticketOwners[senderTicketId] = partner;
        ticketOwners[partnerTicketId] = msg.sender;

        ownerToTicket[msg.sender] = partnerTicketId;
        ownerToTicket[partner] = senderTicketId;

        // Remove the swap offer
        delete swapOffers[partnerTicketId];
    }

    // Place a ticket on resale
    function resaleTicket(uint price) public {
        uint ticketId = getTicketOf(msg.sender);
        require(ticketId != 0, "You do not own a ticket.");
        
        resaleTickets[ticketId] = price;
    }

    // Accept a resale offer
    function acceptResale(uint ticketId) public payable {
        uint resalePrice = resaleTickets[ticketId];
        address currentOwner = ticketOwners[ticketId];

        require(resalePrice > 0, "Ticket not available for resale.");
        require(msg.value == resalePrice, "Incorrect resale price.");
        require(ownerToTicket[msg.sender] == 0, "You already own a ticket.");
        
        uint serviceFee = resalePrice / 10;
        uint refund = resalePrice - serviceFee;

        // Transfer resale funds
        payable(currentOwner).transfer(refund);
        payable(manager).transfer(serviceFee);

        // Transfer ticket ownership
        ticketOwners[ticketId] = msg.sender;
        ownerToTicket[msg.sender] = ticketId;

        // Clear resale ticket record
        delete resaleTickets[ticketId];
        delete ownerToTicket[currentOwner];
    }

    // Check available resale tickets and their prices
    function checkResale() public view returns (uint[] memory, uint[] memory) {
        uint resaleCount = 0;
        
        // Count how many tickets are in resale
        for (uint i = 1; i <= totalTickets; i++) {
            if (resaleTickets[i] > 0) {
                resaleCount++;
            }
        }
        
        // Prepare lists to return resale ticket IDs and prices
        uint[] memory ticketIds = new uint[](resaleCount);
        uint[] memory prices = new uint[](resaleCount);
        
        uint index = 0;
        for (uint i = 1; i <= totalTickets; i++) {
            if (resaleTickets[i] > 0) {
                ticketIds[index] = i;
                prices[index] = resaleTickets[i];
                index++;
            }
        }
        
        return (ticketIds, prices);
    }
}





/*
Compiling your contracts...
===========================
> Compiling .\contracts\TicketSale.sol
> Artifacts written to C:\Users\shish\AppData\Local\Temp\test--56028-EUvx4SmryceD
> Compiled successfully using:
   - solc: 0.8.17+commit.8df45f5f.Emscripten.clang


  Contract: TicketSale
    √ should allow a user to buy a ticket (867ms)
    1) should not allow a user to buy a ticket if already owned

    Events emitted during test:
    ---------------------------

    [object Object].TicketPurchased(
      buyer: 0x4CdC0BeD748F5d67C3C557bf8d9a718A5F7f81AB of unknown class (type: address),
      ticketId: 1 (type: uint256)
    )


    ---------------------------
    2) should allow a ticket owner to offer a swap

    Events emitted during test:
    ---------------------------

    [object Object].TicketPurchased(
      buyer: 0x4CdC0BeD748F5d67C3C557bf8d9a718A5F7f81AB of unknown class (type: address),
      ticketId: 1 (type: uint256)
    )

    [object Object].TicketPurchased(
      buyer: 0x9095844f466B225f31bE6CbFd0157D06D2629A29 of unknown class (type: address),
      ticketId: 2 (type: uint256)
    )

    [object Object].SwapOffered(
      from: 0x4CdC0BeD748F5d67C3C557bf8d9a718A5F7f81AB of unknown class (type: address),
      ticketId: 1 (type: uint256)
    )


    ---------------------------
    3) should allow users to swap tickets

    Events emitted during test:
    ---------------------------

    [object Object].TicketPurchased(
      buyer: 0x4CdC0BeD748F5d67C3C557bf8d9a718A5F7f81AB of unknown class (type: address),
      ticketId: 1 (type: uint256)
    )

    [object Object].TicketPurchased(
      buyer: 0x9095844f466B225f31bE6CbFd0157D06D2629A29 of unknown class (type: address),
      ticketId: 2 (type: uint256)
    )

    [object Object].SwapOffered(
      from: 0x4CdC0BeD748F5d67C3C557bf8d9a718A5F7f81AB of unknown class (type: address),
      ticketId: 1 (type: uint256)
    )


    ---------------------------
    √ should allow a ticket owner to resale a ticket (1622ms)
    √ should allow another user to buy a resale ticket (2556ms)


  3 passing (16s)
  

*/