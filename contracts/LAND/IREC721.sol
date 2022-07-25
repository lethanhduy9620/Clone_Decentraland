// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

interface IREC721 {
    function balanceOf(address holder) external view returns (uint256);

    function ownerOf(uint256 assetId) external view returns (address);

    // function safeTransferFrom(address from, address to, uint256 assetId) external payable;

    // function safeTransferFrom(address from, address to, uint256 assetId, bytes memory userData) external payable;

    function transferFrom(address from, address to, uint256 assetId) external payable;

    // function approve(address operator, uint256 assetId) external payable;

    // function setApprovalForAll(address operator, bool authorized) external;

    // function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address assetHolder, address operator) external view returns (bool);
    
    // function isAuthorized(address operator, uint256 assetId) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed assetId);

    // event Transfer(address indexed from, address indexed to,  uint256 indexed assetId, address operator, bytes userData);

    // event Transfer(address indexed from, address indexed to, uint256 indexed assetId, address operator, bytes userData, bytes operatorData);

    event Approval(address indexed owner, address indexed operator, uint256 indexed assetId);

    event ApprovalForAll(address indexed holder, address indexed operator, bool authorized);
}