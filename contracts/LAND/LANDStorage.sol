// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

contract LANDStorage {
    mapping (address => uint) public latestPing;

    uint256 constant clearLow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
    uint256 constant clearHigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
    uint256 constant factor = 0x100000000000000000000000000000000;

    mapping (address => bool) public authorizedDeploy;
}