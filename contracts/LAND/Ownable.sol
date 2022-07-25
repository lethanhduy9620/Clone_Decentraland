// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "./Storage.sol";

abstract contract Ownable is Storage {
    event OwnerUpdate(address _prevOwner, address _newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "This funciton can only be called by an owner");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner, "Cannot transfer to yourself");
        owner = _newOwner;
    }
}