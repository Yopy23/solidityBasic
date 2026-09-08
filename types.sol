// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Types {
    uint256 number;
    string sentence;
    bool TorF;
    address adres;
    uint[] array;

    function StringSumm(
        string memory _sentence
    ) public pure returns (string memory) {
        string memory newW = _sentence;
        return newW;
    }

    function Num(uint256 _number) public pure returns (uint256) {
        uint256 New = _number;
        if (New > 5) New += 1;
        else New = 0;
        return _number;
    }

    function Age(uint256 age) public pure returns (string memory) {      
        return age <= 18 ? "minor" : "adult";
    }
    
    function updataAddres() public returns(address myAddress){
        adres = msg.sender;
        return adres;
    }
    
    function Arrays(uint[] memory _array, bool _TorF) public returns (uint[] memory postArray) {
        uint length = _array.length;
        uint i=0;
        uint[] storage NewArray = array;
        while (i<length)
            NewArray.push(i++);
        return NewArray;
    }

    function Boolian (bool _TorF) public pure returns (uint256) {
        uint x = 10;
        if (_TorF)
            x *2 + 2;
        else 
            x - 3 % 2;
        return x;
    }
}
