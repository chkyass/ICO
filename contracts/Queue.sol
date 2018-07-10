pragma solidity ^0.4.15;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 */

contract Queue {
    /* State variables */
    uint8 constant size = 5;
    address[size] queue;
    address creator;
    uint8 free;
    uint maxDelay;
    mapping(address => uint) pushTime;

    /* Add events */
    event TimeLimit(address addr);


    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }


    /* Add constructor */
    constructor(uint _maxDelay) {
        creator = msg.sender;
        maxDelay = _maxDelay;
    }


    /* Returns the number of people waiting in line */
    function qsize() public view returns(uint8) {
        return free;
    }


    /* Returns whether the queue is empty or not */
    function empty() public view returns(bool) {
        return free == 0;
    }

    
    /* Returns the address of the person in the front of the queue */
    function getFirst() public view returns(address) {
        return queue[0];
    }

    
    /* Allows `msg.sender` to check their position in the queue */
    function checkPlace() public view returns(uint8) {
        for(uint8 i = 0; i<free; i++) {
            if(msg.sender == queue[i])
                return i;
        }
        return size + 1;
    }


    /* Allows anyone to expel the first person in line if their time
     * limit is up
     */
    function checkTime() external{
        address first = queue[0];
        if((now - pushTime[first]) >= maxDelay){
            dequeue();
            emit TimeLimit(first);
        }
    }
    
    /* Removes the first person in line; either when their time is up or when
     * they are done with their purchase
     */
    function dequeue() public {    
        for(uint8 i = 1; i<free; i++)
            queue[i-1] = queue[i];

        if(free != 0)
            free--;
    }

    /* Places `addr` in the first empty position in the queue */
    function enqueue(address _addr) external {
        for(uint8 i = 0; i<free; i++) {
            if(_addr == queue[i])
                return;
        }
        
        if(free < size) {
            queue[free] = _addr;
            pushTime[_addr] = now;
            free++;
        }
    }
}
