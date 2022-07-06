// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContinuousSale.sol";
import "./MANAToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MANAContinuousSale is ContinuousSale, Ownable {
    using SafeMath for uint256;

    uint256 public constant INFLATION = 8;

    bool public started = false;

    event RateChange(uint256 amount);

    event WalletChange(address wallet);

    constructor(
        uint256 _rate,  
        address payable _wallet, 
        MANAToken _token) ContinuousSale(_rate, _wallet, _token) {}

    // function MANAContinuousSale(
    //     uint256 _rate,
    //     address _wallet,
    //     MANAToken _token
    // ) ContinuousSale(_rate, _wallet, _token) {
    // }

    modifier whenStarted() {
        require(started, "MANAContinuousSale is not started");
        _;
    }

    function start() public onlyOwner {
        require(!started, "MANAContinuousSale is already started");

        // initialize issuance
        uint256 finalSupply = token.totalSupply();
        uint256 annualIssuance = finalSupply.mul(INFLATION).div(100);
        issuance = annualIssuance.mul(BUCKET_SIZE).div(365 days);

        started = true;
    }

    function buyTokens(address beneficiary) whenStarted public payable override {
        super.buyTokens(beneficiary);
    }

    function setWallet(address payable _wallet) public onlyOwner {
        require(_wallet != address(0), "wallet cannot be 0x00");
        wallet = _wallet;
        emit WalletChange(_wallet);
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
        emit RateChange(_rate);
    }

    function unpauseToken() public onlyOwner {
        MANAToken(token).unpause();
    }

    function pauseToken() public onlyOwner {
        MANAToken(token).pause();
    }
}
