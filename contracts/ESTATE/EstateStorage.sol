// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

interface ILANDRegistry {
    function _decodeTokenId(uint256 value) external pure returns(int256 x, int256 y);
    function ownerOfLand(int256 x, int256 y) external view returns(address);
    function exists(int256 x, int256 y) external view returns (bool);
    function transferFrom(address from, address to,uint256 assetId) external;
}

contract EstateStorage {
    address private LANDRegistryAddress;

    ILANDRegistry public landRegistry;

    // From Estate to list of owned LAND ids (LANDs)
    mapping(uint256 => uint256[]) public estateLandIds;

    // From LAND id (LAND) to its owner Estate id
    mapping(uint256 => uint256) public landIdEstate;

    // From Estate id to mapping of LAND id to index on the array above (estateLandIds)
    mapping(uint256 => mapping(uint256 => uint256)) public estateLandIndex;

    // Metadata of the Estate
    mapping(uint256 => string) internal estateData;

    // Operator of the Estate
    mapping (uint256 => address) public updateOperator;

    function _getLANDResgistryAddress() view internal returns (address) {
        return LANDRegistryAddress;
    }
}