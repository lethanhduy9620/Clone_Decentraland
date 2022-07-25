// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "./EstateStorage.sol";
import "./ERC721Estate.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EstateRegistry is EstateStorage, ERC721Estate  {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    using SafeMath for uint;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier canTransfer(uint256 estateId) {
        require(_isApprovedOrOwner(msg.sender, estateId), "Only owner or operator can transfer");    
        _;
    }

    modifier isDestinataryDefined(address destinatary) {
        require(destinatary != address(0), "Destinary's address is 0");
        _;
    } 

    modifier onlyRegistry() {
        require(msg.sender == address(landRegistry), "Only the registry can make this operation");
        _;
    }

    function setLANDRegistry(address _landRegistry) external onlyOwner {
        landRegistry = ILANDRegistry(_landRegistry);
        emit SetLANDRegistry(_landRegistry);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal override view returns(bool) { 
        address tokenOwner = ownerOf(tokenId);
        // Logic ủy quyền sẽ làm khi chuyển sang làm về MarketPlace
        return tokenOwner == spender;
    }

    function mint(address to, string memory metadata) 
    external 
    // onlyRegistry
    returns(uint256) {
        return _mintEstate(to, metadata);
    }

    function _mintEstate(address to, string memory metadata) 
    isDestinataryDefined(to)
    internal    
    returns(uint256) {
        uint256 estateId = _getNewEstateId();
        _mint(to, estateId);
        _updateMetadata(estateId, metadata);
        emit CreateEstate(to, estateId, metadata);
        return estateId;
    }

    function _getNewEstateId() internal view returns(uint256) {
        return totalSupply().add(1);
    }

    function _updateMetadata(uint256 estateId, string memory metadata) internal {
        estateData[estateId] = metadata;
    }

    function pushLandToEstate(uint256 estateId, uint256 landId) public {
        require(_exists(estateId), "Estate does not exist");
        require(landIdEstate[landId] == 0, "Land has already added to Estate");
        // require(registry.ownerOf(landId) == address(this), "The EstateRegistry cannot manage the LAND"); //! Tính năng này build sau
        estateLandIds[estateId].push(landId);
        landIdEstate[landId] = estateId;
        estateLandIndex[estateId][landId] = estateLandIds[estateId].length;
        emit AddLand(estateId, landId);
    }

    function transferLandFromEstate(
        uint256 estateId, 
        uint256 landId, 
        address destinary
    )
    canTransfer(estateId)
    isDestinataryDefined(destinary)
    external 
    {
    require(estateLandIndex[estateId][landId] != 0, "Land is not part of the Estate");   

    uint256[] memory landIdArray = estateLandIds[estateId]; //clone landId array mapping from estateId
    uint256 lastIndexInArray = landIdArray.length.sub(1); //Get lastest index in the array
    uint256 templandId = landIdArray[lastIndexInArray]; //Get lastest element in the array
    uint256 landIdIndex = estateLandIndex[estateId][landId].sub(1); //Get index of the landId that needs to be transfered
      
    // Replace landId that is transfered
    estateLandIndex[estateId][templandId] = landIdIndex.add(1);
    landIdArray[landIdIndex] = templandId;
   

    delete landIdArray[lastIndexInArray];

    estateLandIndex[estateId][landId] = 0; //Remove index of landId from mapping Estate => LandIndex
    landIdEstate[landId] = 0;
    }

    //  -- Event
    event CreateEstate(
        address indexed _owner,
        uint256 indexed _estateId,
        string _data
    );

    event AddLand(
        uint256 indexed _estateId,
        uint256 indexed _landId
    );

    event SetLANDRegistry(
        address indexed _registry
    );
}