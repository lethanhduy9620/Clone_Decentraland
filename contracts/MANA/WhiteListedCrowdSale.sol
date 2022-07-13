// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CrowdSale.sol";

/**
 * @title WhitelistedCrowdsale
 * @dev Extension of Crowsdale where an owner can whitelist addresses
 * which can buy in crowdsale before it opens to the public
 */
abstract contract WhiteListedCrowdSale is Ownable, CrowdSale {
    using SafeMath for uint256;

    // constructor(
    //         uint256 _startTime,
    //         uint256 _endTime,
    //         uint256 _rate,
    //         address _wallet
    //     ) CrowdSale(_startTime, _endTime, _rate, _wallet) {}
        

    // list of addresses that can purchase before crowdsale opens
    mapping(address => bool) internal whitelist;

    //onlyOwner là modifier chỉ cho phép người deploy smart contract này lên chain mới có thể thêm buyer vào whitelist
    function addToWhitelist(address buyer) public onlyOwner {
        require(buyer != address(0x0));
        whitelist[buyer] = true;
    }

    // @return true if buyer is whitelisted
    function isWhitelisted(address buyer) public view returns (bool) {
        return whitelist[buyer];
    }

    // @return true if buyers can buy at the moment
    function validPurchaseInWhiteList() internal view returns (bool) {
        return !hasEnded() && isWhitelisted(msg.sender);
    }
}
