// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

contract AssetRegistryStorage {
    string internal _name;
    string internal _symbol;
    string internal _description;

    //Stores the total count of assets managed by this registry
    uint256 internal _count;

    // Stores an array of assets owned by a given account
    mapping(address => uint256[]) internal _assetsOf;

    // Stores the index of an asset in the `_assetsOf` array of its holder
    mapping(uint256 => uint256) internal _indexOfAsset;

    // Stores the current holder of an asset
    mapping(uint256 => address) internal _holderOf;
  
    // Stores the data associated with an asset
    mapping(uint256 => string) internal _assetData;

    // For a given account, for a given operator, store whether that operator is allowed to transfer and modify assets on behalf of them.
    mapping(address => mapping(address => bool)) internal _operators;

    // Approval array
    mapping(uint256 => address) internal _approval;
}