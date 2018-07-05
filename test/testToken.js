'use strict';

/* Add the dependencies you're testing */
const Token = artifacts.require("./Token.sol");


contract('TokenTest', function(accounts) {
	/* Define your constant variables and instantiate constantly changing 
	 * ones
	 */
    let intialAmount = 1000;
	let token;

	/* Do something before every `describe` method */
	beforeEach(async function() {
		token = await Token.new(1000);
	});

	/* Group test cases together 
	 * Make sure to provide descriptive strings for method arguements and
	 * assert statements
	 */
	describe('Token primary functions', function() {
		it("Check initialisation", async function() {
            let creator = await token.creator.call();
            assert.equal(creator, accounts[0]);
			let totalSuply = await token.totalSupply.call();
			assert.equal(totalSuply.valueOf(), intialAmount);
			let creatorBalance = await token.balanceOf(accounts[0]);
			assert.equal(creatorBalance.valueOf(), intialAmount);
		});
		
		it("Check purchase", async function() {
			try {
				await token.purchase(account[1], 100);
				let buyerBalance = await token.balanceOf(accounts[1]);
				let unsold = await token.balanceOf(accounts[0]);
				assert.equal(buyerBalance.valueOf, 100);
				assert.equal(unsold.valueOf, 900)
				await token.purchase(account[1], 2000);
				buyerBalance = await token.balanceOf(accounts[1]);
				unsold = await token.balanceOf(accounts[0]); 
				assert.equal(buyerBalance.valueOf, 100);
				assert.equal(unsold.valueOf, 900)
				await token.purchase(accounts[1], 5000, {from: accounts[2]});
				throw null;
			} catch (error){}
		});
	
	describe('Token Creator funtions', function(){
		it("Destroy tokens", async function() {
			await token.burn(200);
			let unsold = await token.balanceOf(accounts[0]);
			let total = await token.totalSupply();
			assert.equal(unsold.valueOf(), 800);
			assert.equal(total.valueOf(), 800);
			await token.purchase(accounts[1], 100);
			await token.burn(50,{from: accounts[1]});
			unsold = await token.balanceOf(accounts[1]);
			total = await token.totalSupply();
			assert.equal(unsold.valueOf(), 50);
			assert.equal(total.valueOf(), 750);
		});

		it("Create tokens", async function(){
			await token.mint(2000);
			let total = await token.totalSupply();
			let unsold = await token.balanceOf(accounts[0]);
			assert.equal(total.valueOf(), 3000);
			assert.equal(unsold.valueOf(), 3000);
		});
	});


	});

	describe('Your string here', function() {
		// YOUR CODE HERE
	});
});