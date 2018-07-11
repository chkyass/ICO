pragma solidity ^0.4.15;

import "./interfaces/ERC20Interface.sol";

/**
 * @title Token
 * @dev Contract that implements ERC20 token standard
 * Is deployed by `Crowdsale.sol`, keeps track of balances, etc.
 */

contract Token is ERC20Interface {

    string public constant name = "CHK token";
    string public constant symbole = "CHK";

    //Balances for each account
    mapping(address => uint256) private balances;
    //Owner of account approves the transfer of amount to another account
    mapping(address => mapping(address => uint256)) private allowed;
    address public creator;
    //uint256 public totalSupply;
    
    event Burn(address indexed _owner, uint256 _value);
    event Purchase(address indexed _buyer, uint256 _value);
    event Refund(address indexed _owner, uint256 _value);
    event Mint(uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    function Token(uint256 _amount) public {
        totalSupply = _amount;
        balances[msg.sender] = _amount;
        creator = msg.sender;
    }

    function soldTokens() external view returns(uint256) {
        return totalSupply-balances[creator];
    }

    function balanceOf(address _owner) public view returns(uint256) {        
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external returns(bool) {
        if(balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint256 _value) external returns(bool) {
        if(balances[msg.sender] >= _value) {
            allowed[msg.sender][_spender] += _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        if(balances[_from] >= _value && allowed[_from][_to] >= _value) {
            balances[_from] -= _value;
            allowed[_from][_to] -= _value;
            balances[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function burn(uint256 _value) external returns (bool) {
        if(balances[msg.sender] >= _value) {
            totalSupply -= _value;
            balances[msg.sender] -= _value;
            emit Burn(msg.sender, _value);
            return true;
        }
        return false;
    }

    function mint(uint256 _value) external  isCreator() {
        totalSupply += _value;
        balances[creator] += _value;
        emit Mint(_value);
    }

    function purchase(address _buyer, uint256 _value) external isCreator() returns (bool) {
        if(totalSupply >= _value) {
            balances[creator] -= _value;
            balances[_buyer] += _value;
            emit Purchase(_buyer, _value); 
            return true;
        }
        return false;
    }

    function refund(address _owner, uint256 _value) external isCreator() returns (bool)  {
        if(balances[_owner] >= _value) {
            balances[_owner] -= _value;
            balances[creator] += _value;
            emit Refund(_owner, _value);
            return true;
        }
        return false;
    }

}
