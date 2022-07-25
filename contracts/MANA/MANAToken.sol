// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MANAToken is ERC20, Pausable, Ownable {
    using SafeMath for uint256;

    uint256 private _initialTotalSupply = 2.6*10**9; //uint: token

    uint256 internal _mintedTokenAmount;

    mapping(address => bool) private _authorizedList;
    
    constructor() ERC20("Decentraland MANA", "MANA"){
        mint(msg.sender, _initialTotalSupply);
    } // * ! Bản chính thức thì dùng code này

    // constructor() ERC20("Decentraland MANA", "MANA"){
    //     uint256 _initialSupply = initialTotalSupply;
    //     _mint(msg.sender, _initialSupply);
    // }
    

    //Authorization 
    event Authorize(address owner, address authorizedPerson);

    modifier OnlyAuthorized(address person) {
        require(isAuthorized(person), "This function is only called by authorized people");
        _;
    }

    function isAuthorized(address person) public view returns(bool){
        address owner = owner();
        return _authorizedList[person] || person == owner;
    }

    function authorize(address authorizedPerson) public onlyOwner {
        _authorizedList[authorizedPerson] = true;
        emit Authorize(owner(), authorizedPerson);
    }

    //Logic of Minting Token
    bool public mintingFinished = false;

    event Mint(address indexed to, uint256 amount, uint256 _mintedTokenAmount);
    event MintFinished();

    modifier canMint() {
        require(mintingFinished != true, "Token minting has finished");
        _;
    }
    
    function mint(address beneficiary, uint256 amount) public OnlyAuthorized(msg.sender) canMint returns(bool) {
        _mintedTokenAmount = _mintedTokenAmount.add(amount);
        _mint(beneficiary, amount);
        emit Mint(beneficiary, amount, _mintedTokenAmount);
        return true;
    }

    /*
    * @dev Finish minting token 
    */
    function FinishMinting() public onlyOwner returns(bool) {
        mintingFinished = true;
        emit MintFinished();
        return mintingFinished;
    }

    //Logic of Pausable Token 
    function pause() onlyOwner public {
        super._pause();
    }

    function unpause() onlyOwner public{
        super._unpause();
    }

    function transfer(address to, uint256 amount) public whenNotPaused override returns (bool) {
       return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public whenNotPaused override returns(bool) {
        return super.transferFrom(from, to, amount);
    }

    //Logic of Burnable Token
    /*
    * @dev Burns a specified amount of tokens
    * @param _value The amount of tokens to burn 
    */
    function burn(uint256 amount) public whenNotPaused {
        super._burn(msg.sender, amount);
    }

    //Draft
    function getMintedTokenAmount() view public returns (uint256) {
        return _mintedTokenAmount;
    }

    // function getMANATokenAddress() view external returns(address) {
    //     return address(this);
    // }

    // //Draft bypass allowances
    // function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
    //     _transfer(from, to, amount);
    //     return true;
    // }
}
