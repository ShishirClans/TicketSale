const TicketSale = artifacts.require("TicketSale");

contract("TicketSale", accounts => {
    let // File: test/TicketSale.test.js
const TicketSale = artifacts.require("TicketSale");

contract("TicketSale", accounts => {
    let ticketSale;
    const price = web3.utils.toWei('0.01', 'ether'); // Adjust to your price in Wei
    const numTickets = 100;

    before(async () => {
        ticketSale = await TicketSale.new(numTickets, price);
    });

    it("should buy a ticket", async () => {
        await ticketSale.buyTicket(1, { from: accounts[1], value: price });
        const owner = await ticketSale.getTicketOf(accounts[1]);
        assert.equal(owner.toString(), '1', "Ticket not owned by the buyer");
    });

    it("should allow swapping tickets", async () => {
        await ticketSale.buyTicket(2, { from: accounts[2], value: price });
        await ticketSale.offerSwap(1, { from: accounts[1] });
        await ticketSale.acceptSwap(2, { from: accounts[2] });

        const newOwner1 = await ticketSale.getTicketOf(accounts[1]);
        const newOwner2 = await ticketSale.getTicketOf(accounts[2]);
        assert.equal(newOwner1.toString(), '2', "Ticket not swapped correctly");
        assert.equal(newOwner2.toString(), '1', "Ticket not swapped correctly");
    });

    it("should allow resale of a ticket", async () => {
        await ticketSale.resaleTicket(web3.utils.toWei('0.02', 'ether'), { from: accounts[1] });
        await ticketSale.acceptResale(2, { from: accounts[3], value: web3.utils.toWei('0.02', 'ether') });
        const newOwner = await ticketSale.getTicketOf(accounts[3]);
        assert.equal(newOwner.toString(), '2', "Ticket not resold correctly");
    });

    it("should allow checking resale tickets", async () => {
        const resales = await ticketSale.checkResale();
        assert.isArray(resales, "Resales should be an array");
    });
});
ticketSale;

    const ticketOwner = accounts[1]; // The account that owns the ticket
    const otherUser = accounts[2]; // Another account for testing

    beforeEach(async () => {
        ticketSale = await TicketSale.new();
        // Mint a ticket for the ticket owner before each test
        await ticketSale.mintTicket(ticketOwner, 1);
    });

    it("should not allow a user to buy a ticket if already owned", async () => {
        try {
            await ticketSale.buyTicket(1, { from: ticketOwner });
            assert.fail("Expected error not received");
        } catch (error) {
            assert(error.message.includes("Ticket already owned"), "Error message should indicate ticket already owned");
        }
    });

    it("should allow a ticket owner to offer a swap", async () => {
        await ticketSale.offerSwap(1, { from: ticketOwner });
        
        // Verify if the swap is registered
        const swap = await ticketSale.getSwapOffer(1); // Assuming you have a method to get a swap offer
        assert.equal(swap[0], ticketOwner, "The swap should be offered by the ticket owner");
    });

    it("should allow users to swap tickets", async () => {
        // First, the ticket owner needs to offer a swap
        await ticketSale.offerSwap(1, { from: ticketOwner });

        // Now, the other user can attempt to swap the ticket
        await ticketSale.swapTickets(1, { from: otherUser });

        // Here you would want to verify the swap's success, perhaps by checking ownership
        const newOwner = await ticketSale.getTicketOwner(1); // Assuming you have a method to check ticket ownership
        assert.equal(newOwner, otherUser, "The ticket owner should be updated to the other user");
    });

    it("should allow another user to buy a resale ticket", async () => {
        // Let's say the ticket is listed for resale
        await ticketSale.listForResale(1, { from: ticketOwner });

        // The other user should be able to buy the ticket now
        await ticketSale.buyTicket(1, { from: otherUser });

        const newOwner = await ticketSale.getTicketOwner(1);
        assert.equal(newOwner, otherUser, "The new owner should be the buyer");
    });
});