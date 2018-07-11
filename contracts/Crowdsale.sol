pragma solidity ^0.4.15;

import "./Queue.sol";
import "./Token.sol";

/**
 * @title Crowdsale
 * @dev Contract that deploys `Token.sol`
 * Is timelocked, manages buyer queue, updates balances on `Token.sol`
 */

contract Crowdsale {
    
    address owner;
    uint256 saleDuration;
    uint256 saleStart;

    /* How many tokens you can buy with 1 wei */
    uint256 public exchangeRate;    
    Queue queue;
    Token tokens;

    /* Map an address to the amount waiting to be used to purchase tokens */
    mapping(address => uint256) orders;

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier saleNotOver() {
        require((now - saleStart) < saleDuration);
        _;
    }

    event Purchase(address _owner, uint256 _amount);
    event Refund(address _owner, uint256 _amount);

    constructor(uint256 _initialAmount, uint256 _saleDuration, 
                uint256 _exchangeRate, uint256 _queueMaxDelay) {
        saleDuration = _saleDuration;
        tokens = new Token(_initialAmount);
        queue = new Queue(_queueMaxDelay);
        saleStart = now;
        exchangeRate = _exchangeRate;
        owner = msg.sender;
    }


    function ordersOf(address _spender) external view returns(uint256) {
        return orders[_spender];
    }


    function mint(uint256 _amount) external isOwner() {
        tokens.mint(_amount);
    }


    function burn(uint256 _amount) external isOwner() {
        tokens.burn(_amount);
    }

    /* if sale duration isn't over, if the queue isn't full
     * enqueue the order */
    function order() external payable saleNotOver(){      
        queue.checkTime();
        uint256 qsize = queue.qsize();
        if(qsize < 5) {
            orders[msg.sender] += msg.value;
            queue.enqueue(msg.sender);
        }
    }

    /* if the caller is the first in the queue, there is
     * someone behind him, and he doesn't stayed too long 
     * in the first position of queue, apply the order */
    function buy() external saleNotOver(){
        queue.checkTime();
        if(queue.getFirst() == msg.sender && orders[msg.sender] != 0) {
            if(queue.qsize() > 1) {
                queue.dequeue();
                tokens.purchase(msg.sender, orders[msg.sender]*exchangeRate);
                emit Purchase(msg.sender, orders[msg.sender]);
                delete orders[msg.sender];
            }
        }
    }

    /* Refund tokens*/
    function refund(uint256 _amount) external saleNotOver(){
        uint256 balance = tokens.balanceOf(msg.sender);
        if(balance >= _amount) {
            tokens.refund(msg.sender, _amount);
            if(!msg.sender.send(_amount*exchangeRate)) {
                tokens.purchase(msg.sender, _amount);
                return;
            }
            emit Refund(msg.sender, _amount);
        }
    }

    function getFunds() external isOwner() {
        require(now > saleDuration + saleStart);
        msg.sender.transfer(address(this).balance);
    }

    function () payable {}





}
