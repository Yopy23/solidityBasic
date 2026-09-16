// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 { 
    function totalSupply () external;
    function balanceOf (address) external;
    function transfer (address _to, uint _amount) external;
    function allowance (address _owner, address _spender) external;
    function approve (address spender, uint256 _amount) external returns (bool);
    function transferFrom (address _from, address _to, uint256 _amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract MyCustomToken is IERC20 {
    string name = "ProfiHub Token";
    string symbol = "PHT";
    uint decimals = 18;
    mapping (address => uint256) private _balances; 
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor (uint256 _initialSupply) { // принимает токены, присваивает
        _balances[msg.sender] = _initialSupply * 10 ** 18;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function totalSupply () external {
        
    }

    // проверяет баланс и отсутствие нулевого адреса, переводит токены, генерирует Transfer
    function transfer (address _to, uint _amount ) public { 
        require(_balances[msg.sender] > 0, "balance is 0 tokens");
        require(msg.sender != address(0), "address is 0");

        _balances[msg.sender] -= _amount;
        _balances[_to] += _amount;
    }

    function allowance (address spender) public view {
        _allowances[msg.sender][spender];
    }

    //устанавливает лимит расходов для spender, генерирует Approval
    function approve (address spender, uint _amount) public returns (bool) { 
        _allowances[msg.sender][spender] = _amount;
        emit Approval(msg.sender, spender, _amount);
        return true;
    }

    //позволяет любому держателю уменьшить свой баланс и общий totalSupply
    function burn(uint256 amount) public { 
        require(msg.sender, "only msg sender can do this");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
    }

    // проверяет и уменьшает allowance[from][msg.sender], переводит средства от from к to
    function transferFrom (address _from, address _to, uint256 _amount) public returns (bool) { 
        require(_balances[_from] >= _amount, "sender does not have enough tokens");
        require(_allowances[_from][msg.sender] >= _amount , "the write-off limit has been exceeded");

        _balances[_from] -= _amount;
        _balances[_to] += _amount;
        _allowances[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;

    }
}

contract TokenLocker {
    mapping(address => mapping(address => uint256)) public lockedBalances;

    function lockTokens(address _tokenAddress, uint256 _amount) external {
        _tokenAddress = IERC20(_tokenAddress);
        transferFrom(msg.sender, address(this), _amount); // Забирает токены у msg.sender на адрес самого локера address(this) через transferFrom.
        _balance[msg.sender] -= _amount;
        lockedBalances[_tokenAddress][msg.sender] += _amount; //Увеличивает заблокированный баланс пользователя
    }
}
