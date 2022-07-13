// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

contract ProxyStorage {
    address public currentContract;
    address public proxyOwner;
}