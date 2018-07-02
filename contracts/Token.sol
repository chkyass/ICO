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
    uint8 public constant decimals = 18;

    //Balances for each account
    mapping(address => uint256) private balances;
    //Owner of account approves the transfer of amount to another account
    mapping(address => mapping(address => uint256)) private allowed;

    event Burn(address indexed _owner, uint256 _value);

    constructor(uint256 _amount) {
        totalSupply = _amount;
    }

    function balanceOf(address _owner) public view returns(uint256) {        
        return balances[_owner];
    }

    function transfert(address _to, uint256 _value) public returns(bool) {
        if(balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        if(balances[msg.sender] >= _value) {
            allowed[msg.sender][_spender] += _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if(balances[_from] >= _value && allowed[_from][_to] >= _value) {
            balances[_from] -= _value;
            allowed[_from][_to] -= _value;
            balances[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function burn(uint256 _value) public returns (bool) {
        if(balances[msg.sender] >= _value) {
            totalSupply -= _value;
            balances[msg.sender] -= _value;
            emit Burn(msg.sender, _value);
            return true;
        }
        return false;
    }


}
