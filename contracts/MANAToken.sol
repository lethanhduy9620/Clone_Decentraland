// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol"; 


contract MANAToken is ERC20, Pausable {
    uint256 initialSupply = 1000000000; //uint: token
    
    // constructor(uint256 _initialSupply) ERC20("Decentraland MANA", "MANA"){
    //     _mint(msg.sender, initialSupply);
    // } // * ! Bản chính thức thì dùng code này

      constructor() ERC20("Decentraland MANA", "MANA"){
        uint256 _initialSupply = initialSupply;
        _mint(msg.sender, _initialSupply);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    // //! Get SM token
    // function getSM() view public returns(address) {
    //     return address(this);
    // }
}
