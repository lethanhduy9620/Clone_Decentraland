// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./MANAToken.sol";

/**
 * @title ContinuousSale
 * @dev ContinuousSale implements a contract for managing a continuous token sale
 */
contract ContinuousSale  {
    using SafeMath for uint256;

    // time bucket size
    uint256 public constant BUCKET_SIZE = 12 hours;

    // the token being sold
    MANAToken public token;

    // address where funds are collected
    address payable wallet;

    // amount of tokens emitted per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    // max amount of tokens to mint per time bucket
    uint256 public issuance; //unit: TKNBits
    // uint256 public issuance = 20000*10**18;

    // last time bucket from which tokens have been purchased
    uint256 public lastBucket = 0;

    // amount issued in the last bucket
    uint256 public bucketAmount = 0;

    event TokenPurchase(address indexed investor, address indexed beneficiary, uint256 weiAmount, uint256 tokens);

    constructor(
        uint256 _rate,
        address payable _wallet,
        MANAToken _token //Address of smart contract of this coin
    ) {
        require(_rate != 0, "Rate must not be 0");
        require(_wallet != address(0), "Address of the wall must not be 0");
        require(address(_token) !=  address(0), "Address of SM Token must not be 0");

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }
  
    function buyTokens(address beneficiary) public payable virtual {
        require(beneficiary != address(0), "Address must not be 0");
        require(msg.value != 0, "Value must not be 0");

        // prepareContinuousPurchase(); // ? Không hiểu làm gì nên comment
        uint256 tokens = processPurchase(beneficiary);
        checkContinuousPurchase(tokens);
    }

    function prepareContinuousPurchase() internal {
        uint256 timestamp = block.timestamp;
        uint256 bucket = timestamp - (timestamp % BUCKET_SIZE);

        if (bucket > lastBucket) {
            lastBucket = bucket;
            bucketAmount = 0;
        }
    }

    function checkContinuousPurchase(uint256 tokens) internal {
        uint256 updatedBucketAmount = bucketAmount.add(tokens);
        require(updatedBucketAmount <= issuance, "Updated Bucket Amount should be less than anual issuance");

        bucketAmount = updatedBucketAmount;
    }

    function processPurchase(address beneficiary) internal returns(uint256) {
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();

        return tokens;
    }

    function forwardFunds() internal {
        // wallet for collected fund
        wallet.transfer(msg.value); 
    }

    fallback() external payable {
        buyTokens(msg.sender);
    }

    receive() external payable {
        buyTokens(msg.sender);
    }

}