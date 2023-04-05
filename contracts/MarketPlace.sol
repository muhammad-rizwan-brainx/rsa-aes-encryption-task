// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

struct NFT {
    uint256 id;
    address seller;
    address buyer;
    uint256 price;
    bool sold;
    address paymentToken;
    bytes32 encryptedKeyHash;
}

contract Marketplace is ERC1155, Ownable {
    mapping(uint256 => bytes) private aesKeys;
    mapping(uint256 => bytes32) private publicKeyByTokenBuyer;
    mapping(uint256 => NFT) public nfts;

    constructor()
        ERC1155(
            "https://ipfs.io/ipfs/QmceqiJhxNmcdjg2vdikWgMREyLPjHsVyhDmmDUB5npio8"
        )
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mintWithAesKeyHash(uint256 _tokenId, bytes32 _aesKeyHash)
        external
    {
        _mint(msg.sender, _tokenId, 1, "");
        nfts[_tokenId] = NFT(
            _tokenId,
            msg.sender,
            address(0),
            100,
            false,
            address(0),
            _aesKeyHash
        );
    }

    function buyNFT(
        uint256 _id,
        bytes32 rsaPublicKey,
        address paymentToken
    ) public {
        require(
            IERC20(paymentToken).balanceOf((msg.sender)) >= nfts[_id].price,
            "Not enough balance"
        );
        require(nfts[_id].sold == false, "Already Sold");
        setBuyerPublicKey(_id, rsaPublicKey);
        nfts[_id].sold = true;
        nfts[_id].paymentToken = paymentToken;
        IERC20(paymentToken).transferFrom(
            msg.sender,
            address(this),
            nfts[_id].price
        );
    }

    function setBuyerPublicKey(uint256 _tokenId, bytes32 _publicKey) internal {
        publicKeyByTokenBuyer[_tokenId] = _publicKey;
    }

    function approveSaleAndEncryptAesKey(uint256 _tokenId, bytes memory _aesKey)
        external
    {
        bytes32 aesKeyHash = nfts[_tokenId].encryptedKeyHash;
        require(
            keccak256(_aesKey) == aesKeyHash,
            "AES key hash does not match"
        );
        aesKeys[_tokenId] = rsaEncrypt(
            _aesKey,
            publicKeyByTokenBuyer[_tokenId]
        );
        IERC20(nfts[_tokenId].paymentToken).transferFrom(
            address(this),
            nfts[_tokenId].seller,
            nfts[_tokenId].price
        );
        _safeTransferFrom(msg.sender, nfts[_tokenId].buyer, _tokenId, 1, "");
    }

    function getEncryptedAesKey(uint256 _tokenId)
        external
        view
        returns (bytes memory)
    {
        return aesKeys[_tokenId];
    }

    function rsaEncrypt(bytes memory _data, bytes32 _publicKey)
        public
        view
        returns (bytes memory)
    {
        bytes memory encryptedData = new bytes(_data.length);
        uint256 e = 65537; // RSA public exponent
        uint256 n = uint256(_publicKey); // RSA modulus

        for (uint256 i = 0; i < _data.length; i++) {
            uint256 m = uint256(uint8(_data[i])); // message byte
            uint256 c = modexp(m, e, n);
            encryptedData[i] = bytes1(uint8(c));
        }

        return encryptedData;
    }

    function modexp(
        uint256 base,
        uint256 exponent,
        uint256 modulus
    ) public view returns (uint256 result) {
        assembly {
            let pointer := mload(0x40)
            mstore(pointer, 0x20)
            mstore(add(pointer, 0x20), 0x20)
            mstore(add(pointer, 0x40), 0x20)
            mstore(add(pointer, 0x60), base)
            mstore(add(pointer, 0x80), exponent)
            mstore(add(pointer, 0xa0), modulus)
            let success := staticcall(gas(), 0x05, pointer, 0xc0, pointer, 0x20)
            if success {
                result := mload(pointer)
            }
        }
    }

    function CustomURI(uint256 _id) public view returns (string memory) {
        string memory currentBaseURI = uri(_id);
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(_id),
                        ".json"
                    )
                )
                : "";
    }
}
