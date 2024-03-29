// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ERC721Token {
    string  public name = "Mock DAI Token";
    string  public symbol = "mDAI";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8   public decimals = 18;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // keep track of amount for each address
    mapping(address => uint256) public balanceOf;
    // allowance is the amount of tokens that are allowed to be spent by a certain address
    mapping(address => mapping(address => uint256)) public allowance; //{adresss:{adresss:value}}

    constructor()  {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    // _spender is the address that is allowed to spend _value tokens from msg.sender (token farm)
    // msg.sender is investor
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        // msg.sender is the contract in this case --{investor-> contract->value }
        require(_value <= allowance[_from][msg.sender]); // allowance is a mapping from the owner to the spender
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value; // decrease allowance {investor->contract->value}
        emit Transfer(_from, _to, _value);
        return true;
    }
    // _from is the investor and _to is the contract
    // allowance[investor][contract] = value (value is the amount of tokens that are allowed to be spent by a certain address)
    // allowance[investor][contract] = allowance[investor][contract] - value
    

}