// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "./AssetRegistryStorage.sol";

abstract contract ERC721Metadata is AssetRegistryStorage  {
    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function description() external view returns(string memory) {
        return _description;
    }

    function tokenMetadata(uint256 assetId) external view returns(string memory) {
        return _assetData[assetId];
    }

    function _updateTokenMetaData(uint assetId, string memory data) internal {
        _assetData[assetId] = data;
    }
}