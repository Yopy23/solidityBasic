// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract ProfiCoin is ERC20("Profic", "profi") {
    
    constructor(address owner, uint amount) {
        _mint(owner, amount);
    }

    function transfer(address from, address to, uint amount) public {
        _transfer(from,to,amount);
    }
}
