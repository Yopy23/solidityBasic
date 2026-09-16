// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseAccount{
    address public immutable owner; // поле

     constructor(address _owner){

     }
     function calculateFee(uint256 amount) public view virtual returns (uint256) {
        return amount * 100 / 10000;

     }
     function accountType() public pure virtual returns (string memory){
        return "BASE";
     }
}

contract PremiumAccount is BaseAccount {

    constructor (address _owner) BaseAccount(_owner) {}

    function calculateFee (uint256 _amount) public pure override returns (uint256) {
        return _amount  * 20 / 10000;
    }

    function accountType () public pure override returns (string memory) {
        return "RREMIUM";
    }
}

contract CashbackAccount is BaseAccount {
    constructor (address _owner) BaseAccount(_owner) {}

    function calculateFee (uint _amount) public pure override returns (uint256) {
        uint256 baseAmount = super.calculateFee(_amount);
        uint256 cashbackDiscount = _amount * 10 / 1000;
        
        if (baseAmount > cashbackDiscount) {
            return baseAmount - cashbackDiscount;
        }
        return 0;
    }

    function accountType () public pure override returns (string memory) {
        return "CASHBACK";
    }
}

contract AccountFactory {
    error UnknownAccountType();
    address[] public allAccounts;
    mapping(address => address[]) public userAccounts;

    event AccountCreated(address indexed user, address indexed accountAddress, string accountType);


    function createAccount (string memory _accType) external returns (address) {
        bytes32 accountHash = keccak256(bytes(_accType)); // сохраняем хэш типа аккаунта
        
        if (accountHash == keccak256(bytes("PREMIUM"))) { // определяем prem и сохраняем адрес
            newAccount = address(prem);
            PremiumAccount prem = new PremiumAccount(msg.sender); // создаем экземпляр PremiumAccount  // передаем в constructor (address _owner) адрес владельца
        }
        else if (accountHash == keccak256(bytes("CASHBACK"))) { // определяем cash и сохраняем адрес
            CashbackAccount cash = new CashbackAccount(msg.sender);
            newAccount = address(cash);
        }
        else {
            UnknownAccountType();
        }

        allAccounts.push(newAccount); // добавляем адрес в массив всех аккаунтов
        userAccounts[msg.sender].push(newAccount); // добавляем в маппинг адрес обладателя => адрес контракта обладателя

        emit AccountCreated(msg.sender, newAccount, _accType);
    }
}
