// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

struct NFT {
    uint256 id;
    address seller;
    address buyer;
    uint256 price;
    bool sold;
    bytes32 encryptedKeyHash;
}

contract NFTMarketplace is ERC1155, Ownable {

    mapping(uint256 => bytes) private aesKeys;
    mapping(uint256 => bytes32) private publicKeyByTokenBuyer;
    mapping(uint256 => NFT) public nfts;


    constructor()
        ERC1155(
            "https://ipfs.io/ipfs/QmceqiJhxNmcdjg2vdikWgMREyLPjHsVyhDmmDUB5npio8"
        )
    {
        
    }

    function mintWithAesKeyHash(uint256 _tokenId, bytes32 _aesKeyHash)
        external
    {
        _mint(msg.sender, _tokenId, 1, "");
        nfts[_tokenId] = NFT(_tokenId, msg.sender, address(0) ,100,false ,_aesKeyHash);
        
    }

    function buyNFT(uint256 _id, bytes32  rsaPublicKey) public{
        require(nfts[_id].sold == false, "Already Sold");
        setBuyerPublicKey(_id,rsaPublicKey);
        nfts[_id].sold = true;

    }

    function setBuyerPublicKey(
        uint256 _tokenId,
        bytes32 _publicKey
    ) internal {
        publicKeyByTokenBuyer[_tokenId]= _publicKey;
    }

    function approveSaleAndEncryptAesKey(uint256 _tokenId, bytes memory _aesKey)
        external
        view
    {
        bytes32 aesKeyHash = nfts[_tokenId].encryptedKeyHash;
        require(
            keccak256(_aesKey) == aesKeyHash,
            "AES key hash does not match"
        );
        
    }

    function getEncryptedAesKey(uint256 _tokenId)
        external
        view
        returns (bytes memory)
    {
        return aesKeys[_tokenId];
    }

    function rsaEncrypt(bytes memory encryptedAesKey, uint256 _id)
        public
    {
        aesKeys[_id] = encryptedAesKey;
    }
}
