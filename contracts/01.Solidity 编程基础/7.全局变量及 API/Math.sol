// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Math {

    //计算 (x + y) % k，在任意精度下执行加法再取模，支持大数运算
    function addMod(uint256 a, uint256 b, uint256 k) public pure returns (uint256) {
        uint result = addmod(a, b, k); //(x + y) % k
        return result;
    }

    //计算 (x * y) % k，先进行乘法再取模
    function mulMod(uint256 x ,uint256 y,uint k) public  pure returns(uint) {
        return mulmod(x, y, k);
    }

    //使用 Keccak-256 算法计算哈希值（以太坊的主要哈希算法）
    function hashKeccak256(bytes memory data) public pure returns (bytes32) {
        return keccak256(data);
    }

    //计算 SHA-256 哈希值
    function hashSha256(bytes memory data) public pure returns (bytes32) {
        return sha256(data);
    }

    //计算 RIPEMD-160 哈希值，生成较短的 20 字节哈希值
    function hashRipemd160() public pure returns (bytes20) {
        bytes20 hash = ripemd160(abi.encodePacked("Hello, World!"));
        return hash;
    }

    function ecreCover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) external pure returns (address){
      address signer=  ecrecover(hash, v, r, s);
      return signer;
    }

}