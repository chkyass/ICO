'use strict';

const Crowdsale = artifacts.require("./Crowdsale.sol");

function sleep(seconds) {
    let until = new Date().getTime() + seconds*1000;
    while(new Date().getTime() < until) true;
}

contract('testTemplate', function(accounts) {

    let crowdsale;
    let initialAmount = 1000;
    let saleDuration = 3;
    let exchangeRate = 10;
    let queueMaxDelay = 1;
	
	beforeEach(async function() {
        crowdsale = await Crowdsale.new(initialAmount, saleDuration, 
            exchangeRate, queueMaxDelay);  
	});

	describe('Test', function() {
		it("Check buy: Nobody Behind in the queue and someone behind the queue", async function() {
            await crowdsale.order({from: accounts[1], value: 10});
            let receipt = await crowdsale.buy({from: accounts[1]});
            assert.equal(receipt.logs.length, 0);
            await crowdsale.order({from:accounts[2], value: 20});
            let receipt1 = await crowdsale.buy({from: accounts[1]});
            assert.notEqual(receipt1.logs.length, 0);
        });

        it("Check orders variable modifications", async function() {
            await crowdsale.order({from: accounts[1], value: 10});
            await crowdsale.order({from:accounts[2], value: 20});
            await crowdsale.buy({from: accounts[1]});
            let acc1orders = await crowdsale.ordersOf(accounts[1]);
            assert.equal(acc1orders.valueOf(), 0);
        });

        it("Check refund", async function() {
            await crowdsale.order({from: accounts[1], value: 1000000});
            await crowdsale.order({from: accounts[2], value: 1000000});
            await crowdsale.buy({from: accounts[1]});
            let afterPurchase = await web3.eth.getBalance(accounts[1]);
            await crowdsale.refund(1000000,{from: accounts[1]});
            let afterRefund = await web3.eth.getBalance(accounts[1]);
            assert.isBelow(parseInt(afterRefund.valueOf()), parseInt(afterPurchase.valueOf()));
        });

        it("Check sale over", async function() {
            await crowdsale.order({from: accounts[1], value:1000});
            sleep(saleDuration);
            let error = false;
            try{
                await crowdsale.order({value:2563});
            }
            catch(e){
                error = true;
            }
            assert.equal(error, true);
        });
        
	});

});