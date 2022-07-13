// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./WhiteListedCrowdSale.sol";
import "./CappedCrowdSale.sol";
import "./MANAToken.sol";
import "./MANAContinuousSale.sol";
import "./CrowdSale.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ContinuousSale.sol";

contract MANACrowdSale is CappedCrowdSale, WhiteListedCrowdSale {
    using SafeMath for uint256;

    uint256 public constant TOTAL_SHARE = 100;
    uint256 public constant CROWDSALE_SHARE = 40;
    uint256 public constant FOUNDATION_SHARE = 60;

    // price at which whitelisted buyers will be able to buy tokens
    uint256 public preferentialRate;

    // amount of minted token for crowd sale
    uint256 public crowdSaleMintedToken = 0;

    // customize the rate for each whitelisted buyer
    mapping(address => uint256) public buyerRate;

    // initial rate at which tokens are offered (lowest rate)
    uint256 public initialRate;

    // end rate at which tokens are offered (highest rate)
    uint256 public endRate;

    // crowd share allowance
    uint256 public crowdShareAllowance;

    // continuous crowdsale contract
    MANAContinuousSale public continuousSale;

    event WalletChange(address wallet);

    event PreferentialRateChange(address indexed buyer, uint256 rate);

    event InitialRateChange(uint256 rate);

    event EndRateChange(uint256 rate);

    // uint256 _startTime = 1657271700;
    // uint256 _endTime = 1657442859;
    // uint256 _initialRate = 1000;
    // uint256 _endRate = 500;
    // uint256 _preferentialRate = 200;
    // address _wallet = msg.sender;

    constructor(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _initialRate,
        uint256 _endRate,
        uint256 _preferentialRate,
        address _wallet
    )
        CappedCrowdSale(25000 ether)
        WhiteListedCrowdSale()
        CrowdSale(_startTime, _endTime, _initialRate, _wallet) //create MANAToken thông qua hợp đồng CrowdSale
    {
        require(_initialRate > 0, "Initial rate must be larger then 0");
        require(_endRate > 0, "End rate must be larger then 0");
        require(
            _preferentialRate > 0,
            "Preferential Rate must be larger than 0"
        );
        require(_wallet != address(0), "MANAToken address must not be 0");

        initialRate = _initialRate;
        endRate = _endRate;
        preferentialRate = _preferentialRate;

        continuousSale = _createContinuousToken();
        continuousSale.pauseToken();
    }

    //@ override buyTokens from CrowdSale SC
    function buyTokens(address beneficiary) public payable override {
        require(beneficiary != address(0), "Benificiary address must not be 0");
        require(_validPurchase(), "Crowd Sale is experied");
        require(validPurchaseWithinCap(), "Token is sold out");
        require(validPurchaseInWhiteList(), "Address is not in the whitelist");
        require(_isWithInCrowdShareAllowance(),"Allowance of crowd share exceed its limit");
       
        uint256 weiAmount = msg.value;
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);
        uint256 rate = getRate();

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate); //unit TKNBits (1 TKN = 10^18 TKNbits)

        // update state
        weiRaised = updatedWeiRaised;
        crowdSaleMintedToken.add(tokens); //uint TKNbits, 1 TKN = 1*10^18 TKNBits

        //In CrowdSale contract
        token.mint(beneficiary, tokens); 
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        super._forwardFunds();
    }

    function _createContinuousToken() internal returns(MANAContinuousSale) {
        return new MANAContinuousSale(initialRate, wallet, token);
    }

    function getRate() public view returns(uint256) {
        //some early buyers are offered a discount on the crowdsale price
        if (buyerRate[msg.sender] != 0) {
            return buyerRate[msg.sender];
        }

        // whitelisted buyers can purchase at preferential price before crowdsale ends
        if (isWhitelisted(msg.sender)) {
            return preferentialRate;
        } 

        // otherwise compute the price for the auction
        uint256 elapsed  = block.timestamp - startTime;
        uint256 rateRange = initialRate - endRate; 
        uint256 timeRange = endTime - startTime;

        return initialRate.sub(rateRange.mul(elapsed).div(timeRange));
    }

    function setWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0), "Wallet address can not be 0");
        wallet = payable(_wallet); //update owner's wallet of MANACrowdSale smart contract
        continuousSale.setWallet(wallet); //update owner
        emit WalletChange(_wallet);
    }

    function setBuyerRate(address buyer, uint256 rate) onlyOwner public {
        require(rate != 0, "Rate must be larger than 0");
        require(isWhitelisted(buyer), "Buyer address is not in the white lis");
        require(block.timestamp < startTime, "Buyer rate cannot bet set when crowd sale has started");

        buyerRate[buyer] = rate;
        emit PreferentialRateChange(buyer, rate); 
    }

    function setInitialRate(uint256 rate) onlyOwner public {
        require(rate != 0, "Rate must be larger than 0");
        require(block.timestamp < startTime, "Buyer rate cannot bet set when crowd sale has started"); 

        initialRate = rate;

        emit InitialRateChange(rate);
    }

    function setEndRate(uint256 rate) onlyOwner public {
        require(rate != 0, "Rate must be larger than 0");
        require(block.timestamp < startTime, "Buyer rate cannot bet set when crowd sale has started"); 
        endRate = rate;

        emit EndRateChange(rate);
    }

    function allowcateShare() internal {
        // emit tokens for the foundation
        token.mint(wallet, FOUNDATION_SHARE.mul(token.totalSupply()).div(TOTAL_SHARE));

        // NOTE: cannot call super here because it would finish minting and the continuous sale would not be able to proceed  
    }

    function _isWithInCrowdShareAllowance() view internal returns(bool) {
        return crowdSaleMintedToken =< (CROWDSALE_SHARE.mul(token.totalSupply()).div(TOTAL_SHARE)*(10**18));
    }
}


/**
Những vấn đề còn phải cải tiến:
- Viết hàm để bắt đầu continuous sale sau khi crowdsale kết thúc

*/ 