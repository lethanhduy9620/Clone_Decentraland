// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0;

import "./CrowdSale.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
abstract contract CappedCrowdSale is CrowdSale {
    using SafeMath for uint256;

    uint256 internal cap;

    constructor(
        uint256 _cap
    )  {
        require(_cap > 0, "Cap must be larger than 0");
        cap = _cap;
    } 
    

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchaseWithinCap() internal returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinCap;
  }
}