'use strict';

/* Add the dependencies you're testing */
const Queue = artifacts.require("./Queue.sol");

function sleep(seconds) {
    let until = new Date().getTime() + seconds*1000;
    while(new Date().getTime() < until) true;
}

contract('TestQueue', function(accounts) {

	const args = {};
    let queue;


	/* Do something before every `describe` method */
	beforeEach(async function() {
	    queue = await Queue.new(1);
	});

	/* Group test cases together 
	 * Make sure to provide descriptive strings for method arguements and
	 * assert statements
	 */
	describe('Functionalities modifying state', function() {
		it("Check Timeout", async function() {    
            await queue.enqueue(accounts[1]);
            sleep(2);
            await queue.enqueue(accounts[2]);
            await queue.checkTime();
            let free =  await queue.qsize();
            assert.equal(free, 1);
		});
		
	});

});
