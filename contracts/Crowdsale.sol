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
    uint256 sold;
    Token tokens;
    //How many tokens you can buy with 1 wei
    uint256 public exchangeRate;
    Queue queue;

    mapping(address => uint256) balances;
    mapping(address => uint256) orders;

    modifier isOwner() {
        require(msg.sender == owner);
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


    function mint(uint256 _amount) external isOwner() {
        tokens.mint(_amount);
    }


    function burn(uint256 _amount) external isOwner() {
        tokens.burn(_amount);
    }

    function saleOver() public view returns(bool) {
        if(now  > saleDuration + saleStart)
            return true;
    }

    function order() external payable {
        if (saleOver())
            return;
        
        queue.checkTime();
        uint256 qsize = queue.qsize();
        if(qsize < 5) {
            balances[msg.sender] += msg.value;
            orders[msg.sender] += msg.value;
            queue.enqueue(msg.sender);
        }
    }

    function buy() external {
        if(saleOver())
            return;

        queue.checkTime();
        if(queue.getFirst() == msg.sender) {
            if(queue.qsize() > 1) {
                queue.dequeue();
                tokens.purchase(msg.sender, orders[msg.sender]*exchangeRate);
                emit Purchase(msg.sender, orders[msg.sender]);
                orders[msg.sender] = 0;
            }
        }
    }

    function refund(uint256 _amount) external {
        if(saleOver())
            return;

        if(balances[msg.sender] >= _amount) {
            tokens.refund(msg.sender, _amount*exchangeRate);
            balances[msg.sender] -= _amount;
            orders[msg.sender] -= _amount;
            msg.sender.call.value(_amount);
            emit Refund(msg.sender, _amount);
        }       
    }

    function getFunds() external isOwner() {
        if(saleOver())
            msg.sender.transfer(address(this).balance);
    }

    function () payable {}





}
