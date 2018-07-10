'use strict';

/* Add the dependencies you're testing */
const Crowdsale = artifacts.require("./Crowdsale.sol");

contract('testTemplate', function(accounts) {

    let crowdsale;
	/* Do something before every `describe` method */
	beforeEach(async function() {
        crowdsale = await Crowdsale.new(1000, 5, 10, 3);  
	});

	/* Group test cases together 
	 * Make sure to provide descriptive strings for method arguements and
	 * assert statements
	 */
	describe('Test', function() {
		it("Test buy: Nobody Behind in the queue and someone behind the queue", async function() {
            await crowdsale.order({from: accounts[1], value: 10});
            let receipt = await crowdsale.buy({from: accounts[1]});
            assert.equal(receipt.logs.length, 0);
            await crowdsale.order({from:accounts[2], value: 20});
            let receipt1 = await crowdsale.buy({from: accounts[1]});
            assert.notEqual(receipt1.logs.length, 0);
        });

        it("Test refund", async function() {
            await crowdsale.order({from: accounts[1], value: 1000000});
            let afterPurchase = await web3.eth.getBalance(accounts[1]);
            await crowdsale.refund(100000,{from: accounts[1]});
            let afterRefund = await web3.eth.getBalance(accounts[1]);
            assert.isBelow(parseInt(afterRefund.valueOf()), parseInt(afterPurchase.valueOf()));
        });
        
	});

});