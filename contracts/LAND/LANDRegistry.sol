// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./FullAssetRegistry.sol";
import "./Ownable.sol";
import "./Storage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LANDRegistry is  Storage, Ownable, FullAssetRegistry {
    using SafeMath for uint256;

    constructor() {
        _name = "Decentraland LAND";
        _symbol = "LAND";
        _description = "Contract that stores the Decentraland LAND registry";
    }

    bytes4 private constant InterfaceId_IAssetToken = bytes4(0xa8290f49); //From marketplace

    modifier onlyDeployer() {
        require(authorizedDeploy[msg.sender], "This funciton can only be called by an authorized deployer");
        _;
    }

    modifier onlyOwnerOf(uint256 assetId) {
        require(msg.sender == _ownerOf(assetId), "This function can only be called by the owner of the asset");
        _;
    }

    modifier isCurrentOwner(address from, uint256 assetId) {
        require(_ownerOf(assetId) == from, "This function is not called by the owner of asset");
        _;
    }
    
    modifier isDestinataryDefined(address destinatary) {
        require(destinatary != address(0), "Destinary's address is 0");
        _;
    }

    modifier destinataryIsNotHolder(uint256 assetId, address to) {
        require(_ownerOf(assetId) != to, "Destinary's address is the same as owner");
        _;
    }
    
    //LAND Minting
    function assignNewLand(int x, int y, address beneficiary) public onlyDeployer {
        uint256 assetId = _encodeTokenId(x,y);
        _generate(assetId, beneficiary);
    }

    function assignManyNewLand(int[] memory x, int[] memory y, address beneficiary) public onlyDeployer {
        for (uint i = 0; i < x.length; i++) {
            uint256 assetId = _encodeTokenId(x[i],y[i]);
            _generate(assetId, beneficiary);
        }
    }

    function _encodeTokenId(int256 x, int256 y) internal pure returns(uint256 assetId) {
        require(-1000000 < x && x < 1000000 && -1000000 < y && y < 1000000,"The coordinates should be inside bounds");
        unchecked{
        return ((uint(x) * factor) & clearLow) | (uint(y) & clearHigh);
        }
    }

    function _decodeTokenId(uint256 value) internal pure returns(int256 x, int256 y) {
        x = expandNegative128BitCast((value & clearLow) >> 128);
        y = expandNegative128BitCast(value & clearHigh);
        require(-1000000 < x && x < 1000000 && -1000000 < y && y < 1000000,'The coordinates should be inside bounds');
        return (x,y);
    }

    function expandNegative128BitCast(uint256 value) internal pure returns (int256) {
        if (value & (1 << 127) != 0) {
            return int256(value | clearLow);
        }
        return int256(value);
    }

    //LAND Getters
    function exists(int256 x, int256 y) public view returns (bool) {
        return _exist(_encodeTokenId(x,y));
    }

    function ownerOf(int256 x, int256 y) public view returns(address) {
        return _ownerOf(_encodeTokenId(x,y));
    } 

    function landOf(address owner) public view returns(int256[] memory, int256[] memory) {
        uint256 length = _assetsOf[owner].length;
        int256[] memory x = new int256[](length);
        int256[] memory y = new int256[](length);

        int256 assetX;
        int256 assetY;
        for (uint256 i = 0 ; i < length; i++) {
            (assetX, assetY) = _decodeTokenId(_assetsOf[owner][i]);
            x[i] = assetX;
            y[i] = assetY;
        }
        return (x,y);
    }

    //LAND Transfer

    // Unsafe transfer 
    function transferFrom(address from, address to,uint256 assetId) 
        override
        public 
        payable
        isCurrentOwner(from, assetId)
        isDestinataryDefined(to)
        destinataryIsNotHolder(assetId, to)
    {
        address holder = _holderOf[assetId];
        _removeAssetFrom(holder, assetId); //_assetsOf[assetId] is owner of the asset
        _addAssetTo(to, assetId);
        emit Transfer(from, to, assetId);
    }

    function _removeAssetFrom(address from, uint256 assetId) internal {
        uint256 assetIndex = _indexOfAsset[assetId];
        uint256 lastAssetIndex = _balanceOf(from).sub(1);
        uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

        _holderOf[assetId] = address(0);

        // Insert the last asset into the position previously occupied by the asset to be removed
        _assetsOf[from][assetIndex] = lastAssetId;

        // Resize the array
        _assetsOf[from].pop();

        // Remove the array if no more assets are owned to prevent pollution
        if(_assetsOf[from].length == 0) {
            delete _assetsOf[from];
        } 

        // Update the index of positions for the asset
        _indexOfAsset[assetId] = 0; 
        _indexOfAsset[lastAssetId] = assetIndex;

        _count = _count.sub(1);
    }

    //Authorization
    function authorizeDeploy(address beneficiary) external onlyOwner {
        require(beneficiary != address(0), "Address of beneciary cannot be 0");
        require(authorizedDeploy[beneficiary] == false, "Address is forbiden");
        authorizedDeploy[beneficiary] = true;
        emit DeployAuthorized(owner, beneficiary);
    }

    //Estate Generation
    function setEstateRegistry(address _estateRegistry) external onlyOwner{
        estateRegistry = IEstateRegistry(_estateRegistry);
        emit EstateRegistry(_estateRegistry);
    }

    function createEstate(
        int[] memory x,
        int[] memory y, 
        address beneficiary, 
        string memory metadata) 
        isDestinataryDefined(beneficiary)
        external
        returns(uint256)
    {
        require(x.length > 0, "Input should have at least a coordinate");
        require(x.length == y.length, "Input of coordinates should be the lenght");
        uint256 estateId = estateRegistry.mint(beneficiary, metadata); //mint an estate token for the beneficiary's address
        for (uint i = 0; i < x.length; i++) {
            uint256 landId = _encodeTokenId(x[i], y[i]);
            transferFrom(_ownerOf(landId), address(estateRegistry), landId);
            estateRegistry.pushLandToEstate(estateId, landId); // ! Cách này hiện đang làm là sai. Cách đúng là khi hợp đồng estateRegistry nhận được landId thì mới pushLandToEstate (dùng ERC721Received)
        }

        return estateId;
    }

    //Internal function 
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
    if (_interfaceID == 0xffffffff) {
      return false;
    }
    return _interfaceID == InterfaceId_IAssetToken;
  }

    //Event
    event DeployAuthorized(address indexed _caller, address indexed _deployer);

    event EstateRegistry(address indexed estateRegistry);    
}