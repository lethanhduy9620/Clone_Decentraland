// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ! Bản này là phụ cho contract MANAToken

contract StandardToken is ERC20 {
    uint256 initialSupply = 1000000000;
    
    // constructor(uint256 _initialSupply) ERC20("Decentraland MANA", "MANA"){
    //     _mint(msg.sender, initialSupply);
    // } // * Bản chính thức

      constructor() ERC20("Decentraland MANA", "MANA"){
        uint256 _initialSupply = initialSupply;
        _mint(msg.sender, _initialSupply);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}