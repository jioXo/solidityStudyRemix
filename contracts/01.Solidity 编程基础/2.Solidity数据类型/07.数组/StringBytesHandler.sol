// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StringBytesHandler {
    // 存储用户输入的 string 数组
    string[] public stringList;
    // 存储用户输入的 bytes 数组（字节数组）
    bytes[] public bytesList;

    // ======== String 数组操作 ========
    /**
     * 添加字符串到 stringList
     * @param _str 待添加的字符串
     */
    function addString(string calldata _str) external {
        stringList.push(_str);
    }

    /**
     * 删除 stringList 中指定索引的字符串
     * @param _index 要删除的索引
     */
    function removeString(uint _index) external {
        require(_index < stringList.length, "Index out of bounds");
        // 将最后一个元素移到目标索引，再删除最后一个（节省 gas）
        stringList[_index] = stringList[stringList.length - 1];
        stringList.pop();
    }

    /**
     * 查找字符串在 stringList 中的索引
     * @param _str 待查找的字符串
     * @return 找到的索引（未找到返回 -1）
     */
    function findString(string calldata _str) external view returns (int) {
        for (uint i = 0; i < stringList.length; i++) {
            //对 string 类型的直接比较（如 stringList[i] == _str）是不允许的，因为 string 属于引用类型且 Solidity 未原生支持其直接相等性判断
            if (keccak256(abi.encodePacked(stringList[i])) == keccak256(abi.encodePacked(_str))) {
                return int(i);
            }
        }
        return -1;
    }

    /**
     * 拼接 stringList 中所有字符串
     * @return 拼接后的结果
     */
    function concatAllStrings() external view returns (string memory) {
        // 计算总长度，避免多次内存分配
        uint totalLength = 0;
        for (uint i = 0; i < stringList.length; i++) {
            totalLength += bytes(stringList[i]).length;
        }

        // 拼接字符串
        bytes memory result = new bytes(totalLength);
        uint currentIndex = 0;
        for (uint i = 0; i < stringList.length; i++) {
            bytes memory strBytes = bytes(stringList[i]);
            for (uint j = 0; j < strBytes.length; j++) {
                result[currentIndex] = strBytes[j];
                currentIndex++;
            }
        }
        return string(result);
    }

    // ======== Bytes 数组操作 ========
    /**
     * 添加字节数组到 bytesList
     * @param _bytes 待添加的字节数组
     */
    function addBytes(bytes calldata _bytes) external {
        bytesList.push(_bytes);
    }

    /**
     * 删除 bytesList 中指定索引的字节数组
     * @param _index 要删除的索引
     */
    function removeBytes(uint _index) external {
        require(_index < bytesList.length, "Index out of bounds");
        bytesList[_index] = bytesList[bytesList.length - 1];
        bytesList.pop();
    }

    /**
     * 比较两个字节数组是否相等
     * @param _a 第一个字节数组索引
     * @param _b 第二个字节数组索引
     * @return 是否相等
     */
    function compareBytes(uint _a, uint _b) external view returns (bool) {
        require(_a < bytesList.length && _b < bytesList.length, "Index out of bounds");
        return keccak256(bytesList[_a]) == keccak256(bytesList[_b]);
    }

    /**
     * 截取 bytesList 中指定索引的字节数组（从 start 到 end-1）
     * @param _index 目标字节数组索引
     * @param _start 起始位置（包含）
     * @param _end 结束位置（不包含）
     * @return 截取后的字节数组
     */
    function sliceBytes(uint _index, uint _start, uint _end) external view returns (bytes memory) {
        require(_index < bytesList.length, "Index out of bounds");
        bytes memory original = bytesList[_index];
        require(_start < _end && _end <= original.length, "Invalid slice range");

        bytes memory result = new bytes(_end - _start);
        for (uint i = 0; i < result.length; i++) {
            result[i] = original[_start + i];
        }
        return result;
    }

    // ======== 辅助函数 ========
    /**
     * 获取 stringList 的长度
     */
    function getStringListLength() external view returns (uint) {
        return stringList.length;
    }

    /**
     * 获取 bytesList 的长度
     */
    function getBytesListLength() external view returns (uint) {
        return bytesList.length;
    }

    /**
     * 将 string 转换为 bytes 并返回
     * @param _str 待转换的字符串
     */
    function stringToBytes(string calldata _str) external pure returns (bytes memory) {
        return bytes(_str);
    }

    /**
     * 将 bytes 转换为 string 并返回
     * @param _bytes 待转换的字节数组
     */
    function bytesToString(bytes calldata _bytes) external pure returns (string memory) {
        return string(_bytes);
    }
}