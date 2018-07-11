'use strict';

const Queue = artifacts.require("./Queue.sol");

function sleep(seconds) {
    let until = new Date().getTime() + seconds*1000;
    while(new Date().getTime() < until) true;
}

contract('TestQueue', function(accounts) {

	const args = {};
    let queue;


	beforeEach(async function() {
	    queue = await Queue.new(1);
	});

	describe('Test', function() {
        it("Check enqueue", async function() {
            await queue.enqueue(accounts[1]);
            await queue.enqueue(accounts[1]);
            let free = queue.qsize();
            assert(free, 1);
        });

		it("Check Timeout", async function() {    
            await queue.enqueue(accounts[1]);
            sleep(2);
            await queue.enqueue(accounts[2]);
            await queue.checkTime();
            let free =  await queue.qsize();
            assert.equal(free, 1);
            sleep(2);
            await queue.checkTime();
            free = await queue.qsize();
            assert.equal(free, 0);
        });
        
	});

});
