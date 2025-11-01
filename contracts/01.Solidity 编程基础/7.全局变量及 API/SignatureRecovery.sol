// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 导入 OpenZeppelin 的 Strings 库
import "@openzeppelin/contracts/utils/Strings.sol";
contract SignatureRecovery {
    // 生成带前缀的消息哈希（符合 EIP-191 标准）
    function getMessageHash(string memory message) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(bytes(message).length), message)
        );
    }

    // 从签名中恢复地址
    function recoverSigner(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        address signer = ecrecover(messageHash, v, r, s);
        require(signer != address(0), "Invalid signature");
        return signer;
    }

    // 验证消息是否由指定地址签名
    function verifySignature(
        string memory message,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address expectedSigner
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(message);
        return recoverSigner(messageHash, v, r, s) == expectedSigner;
    }
}