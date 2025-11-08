// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address _to, uint256 _amount) public {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 fromBalance = balanceOf[msg.sender];
        require(fromBalance >= _amount, "ERC20: transfer amount exceeds balance");
        balanceOf[msg.sender] = fromBalance - _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        uint256 fromBalance = balanceOf[_from];
        require(fromBalance >= _amount, "ERC20: transfer amount exceeds balance");
        
        uint256 currentAllowance = allowance[_from][msg.sender];
        require(currentAllowance >= _amount, "ERC20: insufficient allowance");
        allowance[_from][msg.sender] = currentAllowance - _amount;

        balanceOf[_from] = fromBalance - _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }
}
