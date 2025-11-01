// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**
ABI 编码及解码函数 API
ABI（应用二进制接口）函数用于编码和解码 Solidity 中的数据类型，特别适用于合约间交互时处理复杂数据结构。
*/
contract ABItest {
    //对输入的参数进行 ABI 编码，返回字节数组
    function abiEncode(
        uint256 a,
        address b
    ) public pure returns (bytes memory) {
        bytes memory encodeData = abi.encode(a, b);
        return encodeData;
    }

    //将多个参数进行紧密打包编码，不填充到 32 字节。适用于哈希计算
    function abiEncodePacked(
        uint256 a,
        address b
    ) public pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }

    //将参数编码，并在前面加上函数选择器（用于外部调用）
    function abiEncodeWithSelector() public pure returns (bytes memory) {
        bytes4 selector = bytes4(keccak256("transfer(address,uint256)"));
        bytes memory encodedWithSelector = abi.encodeWithSelector(
            selector,
            address(0x123),
            100
        );
        return encodedWithSelector;
    }

    //通过函数签名生成函数选择器，并将参数编码
    function abiEncodeWithSignature() public pure returns (bytes memory) {
        bytes memory encodedWithSignature = abi.encodeWithSignature(
            "transfer(address,uint256)",
            address(0x123),
            100
        );
        return encodedWithSignature;
    }

    //对编码的数据进行解码，返回解码后的参数
    function abiDecode() public pure returns (uint256, address) {
        //解析encodeWithSignature和encodeWithSelector时需要移除前四个字节
        bytes memory encodedData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            address(0x123),
            100
        );
        bytes memory dataWithoutSelector = new bytes(encodedData.length - 4);
        for (uint i = 0; i < dataWithoutSelector.length; i++) {
            dataWithoutSelector[i] = encodedData[i + 4];
        }
        (address a, uint b) = abi.decode(
            dataWithoutSelector,
            (address, uint256)
        );
        return (b, a);
    }
}
