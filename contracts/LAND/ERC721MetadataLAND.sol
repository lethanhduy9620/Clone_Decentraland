// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "./AssetRegistryStorage.sol";

interface IERC721Metadata  {
    /*
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /*
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /*
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

abstract contract ERC721MetadataLAND is IERC721Metadata, AssetRegistryStorage  {
    function name() external view override returns(string memory) {
        return _name;
    }

    function symbol() external view override returns(string memory) {
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