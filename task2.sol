// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleAccessHub {
    error NotOwner(address caller); //— вызывающий не является владельцем;
    error AccountBlacklisted(address account); // — аккаунт находится в черном списке;
    error ContractIsPaused(); // — вызов во время действия паузы;
    error InvalidAddress(); // — передан нулевой адрес;
    error InsufficientAccessLevel(uint256 current, uint256 required); // — недостаточный уровень доступа;
    error InvalidLevelValue(uint256 level); // — недопустимое значение уровня доступа (например, выше 5).

    
    address public owner;
    bool public isPaused;
    address[] public blacklistedOwners;
    uint[] public ownerAccessLevels;
    mapping(address => bool) public isBlacklisted;
    mapping(address => uint) public userAccessLevel;
    
    event Log(string message);
    
    constructor (address _initialOwner) {
        owner = _initialOwner;
        require(_initialOwner != address(0), "");
        emit Log("Owner is initialized now!!!");
    }

// разрешает вызов только владельцу контракта (msg.sender == owner), иначе revert NotOwner(msg.sender).
    modifier onlyOwner () {
        if (msg.sender != owner)
            revert NotOwner(msg.sender); // require(msg.sender == owner, NotOwner(msg.sender))
        _;
    }
//  проверяет, что указанный адрес (не msd.sender) не в бане, иначе revert AccountBlacklisted(account).
    modifier notBlackListed(address account) {// address account) { // переменная на входе должна быть объявлена
        if(isBlacklisted[account])
            revert AccountBlacklisted(account);
        _;
    }
//  проверяет, что контракт активен, иначе revert ContractIsPaused()
    modifier whenNotPaused () {
        if(isPaused)
            revert ContractIsPaused();
        _;
    }
// проверяет, что уровень вызывающего >= minLevel.
    modifier requireLevel(uint minLevel) {// uint256 minLevel) 
        require(userAccessLevel[owner] >= minLevel);
        _;
    }

//  переключает паузу (isPaused = !isPaused).
    function togglePause() external onlyOwner {
        if(isPaused) {
            isPaused = !isPaused;
            emit Log("contract is active now");
        }
        else {
            emit Log("contract is already active");
        }
    }

//  блокирует/разблокирует адрес.
    function setBlacklist(address _account, bool _status) external onlyOwner {
        _account = owner;
        if (_status = true) {// true - разблокирован
            isBlacklisted[owner] = false;
        }
        else {
            isBlacklisted[owner] = true;
        }

        }
//  выставляет уровень (1–5).
    function setUserLevel(address _account, uint256 _level) external onlyOwner {
        _account = owner;
        if (_level > 0 && _level <= 5)
            ownerAccessLevels.push(_level);
        else 
            revert InvalidLevelValue(_level);
    }
// операция, требующая одновременного выполнения всех условий.
    function criticalOperation() external whenNotPaused notBlackListed(msg.sender) requireLevel(3) view returns (bool) {
        return true;
    }

}
