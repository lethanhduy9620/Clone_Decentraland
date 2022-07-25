// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./MANAToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract CrowdSale {
    using SafeMath for uint256;

    // The token being sold
    MANAToken public token;
 
    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address payable public wallet;

    // how many token units a buyer gets per wei. Example: 1 wei = 1000 TKNbits
    uint256 public rate; 

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    constructor(
        address tokenAddress,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet
    ) {
        // require() (isContract gì đấy để check token đã deploy hay chưa)
        require(_startTime >= block.timestamp, "startTime is invalid");
        require(_endTime >= _startTime, "endTime must be large than startTime");
        require(_rate > 0, "rate must be positive value");
        require(_wallet != address(0), "wallet must not be 0");

        token = MANAToken(tokenAddress);  //Token là một cái instance của Mintable Token (hình như là chứa address SC MANAToken)
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = payable(_wallet);

        // startTime = 1657270150;
        // endTime = 1658656224;
        // rate = 1000;
        // wallet = payable(msg.sender);
    }

    // function _createTokenContract() internal returns (MANAToken) {
    //     return new MANAToken(); // ? Nghiên cứu lại xem nếu như vậy là nó sẽ tự tạo lấy địa chỉ của smart contract => Lệnh này sẽ tự tạo ra một instance of MANAToken chứa địa chỉ của MANAToken
    // }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable virtual {
        require(beneficiary != address(0), "Address can not be 0");
        require(_validPurchase(), "Purchase is invalid");

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        _forwardFunds();
    }

    // @return true if the transaction can buy tokens
    function _validPurchase() internal returns (bool) {
        bool withinPeriod = block.timestamp >= startTime && block.timestamp <= endTime;
        bool nonZeroPurchase = (msg.value != 0);
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        return block.timestamp > endTime;
    }

    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // fallback function can be used to buy tokens
    receive() external payable {
        buyTokens(msg.sender);
    }

    fallback() external payable {
        buyTokens(msg.sender);
    }
}
