// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Estate is ERC721  {
    constructor() ERC721("Estate", "EST") {}

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] internal allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) internal allTokensIndex;

    // Optional mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;

    // Gets the token ID at a given index of the tokens list of the requested owner
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns(uint256) {
        require(_index < balanceOf(_owner), "Index exceeds blance of the owner");
        return ownedTokens[_owner][_index];
    }

    // Gets the total amount of tokens stored by the contract
    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    // Gets the token ID at a given index of all the tokens in this contract
    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        return allTokens[_index];
    }

    function _mint(address _to, uint256 _tokenId) override internal {
        super._mint(_to, _tokenId);
        allTokensIndex[_tokenId] = allTokens.length; 
        allTokens.push(_tokenId);
    }
}