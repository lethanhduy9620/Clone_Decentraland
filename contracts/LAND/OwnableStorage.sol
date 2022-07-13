// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

abstract contract OwnableStorage {
    address public owner;

    constructor() {
        owner = msg.sender;
    }
}

