// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";


interface IMANAToken {
    function transferFrom(address from, address to, uint256 amount) external returns(bool success);
}

interface IAssetToken { //Interface of SC LANDRegistry or ESTATERegsitry
    function ownerOf(uint256 assetId) external view returns (address owner);
    function approve(address operator, uint256 assetId) external;
    function getApproved(uint256 assetId) external view returns (address);
    function isApprovedForAll(address assetHolder, address operator) external view returns (bool);
    function transferFrom(address from, address to,uint256 assetId) external payable;
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool);
}

contract Marketplace is Pausable, Ownable {
    using SafeMath for uint256;
    using Address for address;

    IMANAToken public manaToken;
    IAssetToken public NFTRegistry;

    address public _marketPlaceOwner;

    constructor() {
        _marketPlaceOwner = msg.sender;
    }

    struct Order {
        bytes32 id; // Order ID
        address seller; // seller's address wallet
        address nftAddress; //Address of SC where asset is registered
        uint256 price; // Price (in wei) for the published item
        uint256 expiresAt; // Time when this sale ends
    }

    //Mapping orderByAssetId: Address of NFTRegistry => AssetId => Order 
    mapping(address => mapping(uint256 => Order)) public orderByAssetId;

    uint256 private _publicationFeeInWei;
    uint256 private _commissionForMarket; //unit: percent %

    bytes4 public constant IAssetToken_interfaceID = bytes4(0xa8290f49);

    function setPublicationFee(uint256 _publicationFee) external onlyOwner{
        _publicationFeeInWei = _publicationFee;
        emit ChangedPublicationFee(_publicationFeeInWei);
    }

    function setCommissionFee(uint256 _commissionFee) external onlyOwner{
        _commissionForMarket = _commissionFee;
        emit ChangedCommissionForMarket(_commissionForMarket);
    }

    function initailize(address _acceptedToken) public {
        manaToken = IMANAToken(_acceptedToken);
    }

    //Event
    event OrderCreated(
        bytes32 id,
        uint256 indexed assetd,
        address indexed seller,
        address nftAddress,
        uint256 priceInWei,
        uint256 expiresAt
    );

    event OrderSuccessful(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 totalPrice,
        address indexed buyer
    );

    event OrderCanceled(
        bytes32 id, 
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress
    );

    event ChangedPublicationFee(uint256 publicationFee);
    event ChangedCommissionForMarket(uint256 commissionFee);

    /*
    * @dev Creates new order (publish NFT to marketplace)
    * @param nftAddress Address of SC where asset is registered
    * @param assetId Address of SC where asset is registered
    * @param priceInWei - Price in wei for published NFT on marketplace
    * @param expiresAt - Time when this sale ends
    */
    function createOrder(
        address nftAddress, 
        uint256 assetId, 
        uint256 priceInWei, 
        uint256 expiresAt
    ) public  
    whenNotPaused
    {
        _requireERC721(nftAddress);
        NFTRegistry = IAssetToken(nftAddress);
        address assetOwner = NFTRegistry.ownerOf(assetId);
        require(msg.sender == assetOwner, "This function is only called by the asset owner");
        require(NFTRegistry.getApproved(assetId) == address(this), "The contract of Marketplace is not authorized to manage this asset");
        require(priceInWei > 0, "The price must be larger than 0");
        require(expiresAt > block.timestamp.add(1 minutes), "Publication should be more than 1 minute before expire time");

        bytes32 orderId = keccak256(abi.encodePacked(
            block.timestamp,
            assetOwner,
            assetId,
            nftAddress,
            priceInWei
        ));

        orderByAssetId[nftAddress][assetId] = Order({
            id: orderId,
            seller: assetOwner, 
            nftAddress: nftAddress,
            price: priceInWei, 
            expiresAt: expiresAt
        });

        if(_publicationFeeInWei > 0) {
            require(manaToken.transferFrom(msg.sender,  _marketPlaceOwner, _publicationFeeInWei), "Transfering the publication fee to marketplace owner failed");
        }

        emit OrderCreated(orderId, assetId, assetOwner, nftAddress, priceInWei, expiresAt);
    }


    function cancelOrder(address nftAddress, uint256 assetId) public {
        Order memory order = orderByAssetId[nftAddress][assetId];
        
        require(order.id != 0, "Asset has not been published on the marketplace");
        require(msg.sender == _marketPlaceOwner || msg.sender == order.seller, "This funciton is called by authorized owner");

        bytes32 orderId = order.id;
        address orderSeller = order.seller;
        delete orderByAssetId[nftAddress][assetId];

        emit OrderCanceled(orderId, assetId, nftAddress, orderSeller);
    }

    function executeOrder(address nftAddress, uint256 assetId, uint256 price
    // bytes fingerprint
    ) public {
       _requireERC721(nftAddress);
       NFTRegistry = IAssetToken(nftAddress);
       Order memory order = orderByAssetId[nftAddress][assetId];
       require(order.id != 0, "Asset not published");
       address seller = order.seller;
       
        require(seller != address(0), "This address seller cannot be 0");
        require(seller != msg.sender, "Purchaser cannot be seller");
        require(order.price == price, "The input price is invalid");
        require(block.timestamp < order.expiresAt, "The order is expired");
        require(seller == NFTRegistry.ownerOf(assetId), "The seller is no longer the asset owner");

        //Calculate commision money and transfer to marketplace for selling NFT
        uint256 commissionMoney = price.mul(_commissionForMarket).div(100);
        require(manaToken.transferFrom(msg.sender, _marketPlaceOwner, commissionMoney), "Transfering commission money for marketplace failed");
        
        //Transfer money to seller
        require(manaToken.transferFrom(msg.sender, seller, price.sub(commissionMoney)), "Transfering net money to seller failed");

        //Transfer NFT from seller to buyer
        NFTRegistry.transferFrom(seller, msg.sender, assetId);

        emit OrderSuccessful(order.id, assetId, seller, nftAddress, price, msg.sender);
    }


    function _requireERC721(address nftAddress) internal {
        require(nftAddress.isContract(), "The address of NFT Registry is not a contract");        

        NFTRegistry = IAssetToken(nftAddress);
        
        require(NFTRegistry.supportsInterface(IAssetToken_interfaceID), "This NFT Registry does not support this interface");
    }

     function getIAssetToken() public pure returns(bytes4) {
        return type(IAssetToken).interfaceId; 
    }
}
