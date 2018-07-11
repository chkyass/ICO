'use strict';

const Token = artifacts.require("./Token.sol");


contract('TokenTest', function(accounts) {

	let token;

	beforeEach(async function() {
		token = await Token.new(1000);
	});


	describe('Token primary functions', function() {
		it("Check initialisation", async function() {
            let creator = await token.creator.call();
            assert.equal(creator, accounts[0]);
			let totalSuply = await token.totalSupply.call();
			assert.equal(totalSuply.valueOf(), 1000);
			let creatorBalance = await token.balanceOf(accounts[0]);
			assert.equal(creatorBalance.valueOf(), 1000);
		});
		
		it("Check purchase", async function() {			
				/* Normal purchase*/
				await token.purchase(accounts[1], 100);
				let buyerBalance = await token.balanceOf(accounts[1]);
				let unsold = await token.balanceOf(accounts[0]);
				assert.equal(buyerBalance, 100);
				assert.equal(unsold, 900)
				/*Purchase more than available */
				await token.purchase(accounts[1], 2000);
				buyerBalance = await token.balanceOf(accounts[1]);
				unsold = await token.balanceOf(accounts[0]); 
				assert.equal(buyerBalance, 100);
				assert.equal(unsold, 900);
				/*Try to purchase with another account that the creator */
				let error = false;
				try {
					await token.purchase(accounts[1], 5000, {from: accounts[2]});
				}
				catch(e){
					error = true;
				}
				assert.equal(error, true);	
		});	
	});
	
	describe('Token Creator functions', function() {
		it("Destroy tokens", async function() {
			await token.burn(200);
			let unsold = await token.balanceOf(accounts[0]);
			let total = await token.totalSupply();
			assert.equal(unsold,800);
			assert.equal(total, 800);
			await token.purchase(accounts[1], 100);
			await token.burn(50,{from: accounts[1]});
			unsold = await token.balanceOf(accounts[1]);
			total = await token.totalSupply();
			assert.equal(unsold, 50);
			assert.equal(total, 750);
		});

		it("Create tokens", async function() {
			await token.mint(2000);
			let total = await token.totalSupply();
			let unsold = await token.balanceOf(accounts[0]);
			assert.equal(total, 3000);
			assert.equal(unsold, 3000);
		});
	});

	describe('Allowance', function() {
		it("Transfer From", async function() {
			await token.purchase(accounts[1], 50);
			await token.approve(accounts[2], 25,{from:accounts[1]});
			let allowance = await token.allowance(accounts[1], accounts[2]);
			assert.equal(allowance, 25);
			await token.transferFrom(accounts[1], accounts[2], 25);
			await token.transferFrom(accounts[1], accounts[2], 1);
			let acc1bal = await token.balanceOf(accounts[1]);
			let acc2bal = await token.balanceOf(accounts[2]);
			allowance = await token.allowance(accounts[1], accounts[2]);
			assert.equal(acc1bal, 25);
			assert.equal(acc2bal, 25);
			assert.equal(allowance, 0);
		});
	});
});
