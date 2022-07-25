// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "./AssetRegistryStorage.sol";

abstract contract ERC721Enumerable  is AssetRegistryStorage {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256) {
        return _count;
    }

    /*
     * @notice Get all tokens of a given address
     * @dev This is not intended to be used on-chain
     * @param owner address of the owner to query
     * @return a list of all assetIds of a user
     */
    function tokenOf(address owner) external view returns (uint256[] memory) {
        return _assetsOf[owner];
    }

    /*
     * @notice Enumerate tokens assigned to an owner
     * @dev Throws if `index` >= `balanceOf(owner)` or if
     *  `owner` is the zero address, representing invalid assets.
     *  Otherwise this must not throw.
     * @param owner An address where we are interested in assets owned by them
     * @param index A counter less than `balanceOf(owner)`
     * @return The identifier for the `index`th asset assigned to `owner`,
     *   (sort order not specified)
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256 assetId) {
        require(index < _assetsOf[owner].length, "Index of token is invalid");
        return _assetsOf[owner][index];
    }
}
