// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol"; 
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MANAToken is ERC20, Pausable {
    using SafeMath for uint256;

    uint256 initialTotalSupply = 1000000000; //uint: token

    uint256 internal _mintedTokenAmount = 0;
    
    constructor(uint256 _initialSupply) ERC20("Decentraland MANA", "MANA"){
        _mint(msg.sender, initialSupply);
    } // * ! Bản chính thức thì dùng code này

    // constructor() ERC20("Decentraland MANA", "MANA"){
    //     uint256 _initialSupply = initialTotalSupply;
    //     _mint(msg.sender, _initialSupply);
    // }

    function mint(address account, uint256 amount) external {
        _mintedTokenAmount.add(amount);
        _mint(account, amount);
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    function getMintedTokenAmount() view public returns (uint256) {
        return _mintedTokenAmount;
    }

    function getMANATokenAddress() view external returns(address) {
        return address(this);
    }

}
