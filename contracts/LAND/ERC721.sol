// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0; 

import "./AssetRegistryStorage.sol";
import "./IERC165.sol";
import "./IREC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract ERC721 is AssetRegistryStorage, IERC165, IREC721 {
    using SafeMath for uint256;

    /*
     * @dev Queries what address owns an asset. This method does not throw.
     * In order to check if the asset exists, use the `exists` function or check if the
     * return value of this call is `0`.
     * @return uint256 the assetId
     */
    function ownerOf(uint256 assetId) external view override returns (address) {
        return _ownerOf(assetId);
    }

    function _ownerOf(uint256 assetId) internal view returns (address) {
        return _holderOf[assetId];
    }

    /*
     * @dev Gets the balance of the specified address
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) external override view returns (uint256) {
        return _balanceOf(owner);
    }

    function _balanceOf(address owner) internal view returns (uint256) {
        return _assetsOf[owner].length;
    }

    /*
     * @dev Query whether an address has been authorized to move any assets on behalf of someone else
     * @param operator the address that might be authorized
     * @param assetHolder the address that provided the authorization
     * @return bool true if the operator has been authorized to move any assets
     */
    function isApprovedForAll(address assetHolder, address operator) external view override returns (bool) {
        return _operators[assetHolder][operator];
    }

    /*
     * @dev Query what address has been particularly authorized to move an asset
     * @param assetId the asset to be queried for
     * @return bool true if the asset has been approved by the holder
     */
    function getApproved(uint256 assetId) public view returns (address) {
        return _approval[assetId];
    }



     /**
     * @dev Authorize a third party operator to manage one particular asset
     * @param operator address to be approved
     * @param assetId asset to approve
     */
     function approve(address operator, uint256 assetId) external {
        address holder = _ownerOf(assetId);
        require(msg.sender == holder, "This funciton is only called by asset owner");
        require(operator != holder, "Operator cannot call this function for asset owner");

        if (getApproved(assetId) != operator) {
            _approval[assetId] = operator;
            emit Approval(holder, operator, assetId);
        }
    }


    // -- Internal function
    function _addAssetTo(address to, uint256 assetId) internal {
        _holderOf[assetId] = to;
        uint256 length = _balanceOf(to);
        _assetsOf[to].push(assetId);
        _indexOfAsset[assetId] = length;
        _count = _count.add(1);
    }

    // -- Generate token Id
    function _generate(uint assetId, address beneficiary) internal {
        require(_holderOf[assetId] == address(0));
        _addAssetTo(beneficiary, assetId);

        emit Transfer(address(0), beneficiary, assetId);
    }

    function _exist(uint256 assetId) internal view returns(bool)  {
        return _holderOf[assetId] != address(0);
    }
}