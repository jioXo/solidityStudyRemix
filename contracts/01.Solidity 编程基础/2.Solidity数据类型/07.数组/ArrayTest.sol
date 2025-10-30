// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
数组是一种用于存储相同类型元素的集合。在 Solidity 中，数组类型可以通过在数据类型后添加 [] 来定义。
Solidity 支持两种数组类型：静态数组（Fixed-size Arrays）和动态数组（Dynamic Arrays）。
*/
contract ArrayTest {
    //静态数组：长度在定义时固定，之后无法改变
    uint[10] public tens; // 一个长度为 10 的 uint 类型静态数组
    string[4] public adArr = ["This", "is", "an", "array"]; // 初始化的静态数组

    //动态数组:长度可变，可以根据需要动态调整
    uint[] public many; // 一个动态长度的uint类型数组
    uint[] public u = [1, 2, 3]; // 动态数组的初始化

    //通过new关键字创建动态数组
    uint[] a = new uint[](7);

    //特殊数组类型： bytes 和 string

    //bytes 是一个动态分配大小的字节数组，类似于 byte[]，但 gas 费用更低。
    bytes bs = "abc\x22\x22"; // 通过十六进制字符串初始化
    bytes public _data = new bytes(10); // 创建一个长度为 10 的字节数组

    //string 用于存储任意长度的字符串（UTF-8编码），对字符串进行操作时用到
    //注意：string 不支持使用下标索引进行访问，需要先转换为 bytes 类型，而 bytes 类型本身是支持下标索引访问的。
    string str0;
    string str1 = "TinyXiong\u718A"; // 使用Unicode编码值

    //地址数组
    address[] myAddress;

    /**
    数组成员属性和函数：

    length 属性：返回数组当前长度（只读），动态数组的长度可以动态改变。
    push()：用于动态数组，在数组末尾添加新元素并返回元素引用。
    pop()：从数组末尾删除元素，并减少数组长度。
    */
    function test1() public returns (uint) {
        many.push(1);
        many.push(2);
        return many.length;
    }

    /**
    多维数组
    */
    function test2() public pure returns (uint) {
        uint[][5] memory multiArray; // 一个元素为变长数组的静态数组
        // 先创建长度为2的uint256动态数组（memory）
        uint256[] memory temp = new uint256[](2);
        temp[0] = 1;
        temp[1] = 2;
        multiArray[2] = temp; // 赋值给multiArray[2]
        uint element = multiArray[2][1]; // 访问第三个动态数组的第二个元素
        return element;
    }

    /**
    数组切片:数组切片是数组的一段连续部分，通过 [start:end] 的方式定义。
    */
    function sliceArray(bytes calldata _payload) external {
        bytes4 sig = abi.decode(_payload[:4], (bytes4)); // 解码函数选择器
        address owner = abi.decode(_payload[4:], (address)); // 解码地址
    }

    /**
    管理地址
    */
    function useAddress(address _addAddress) public {
        myAddress.push(_addAddress);
    }

    /**
    实现一个函数，接收数组作为参数并返回其元素之和
    */
    function sumArray(uint[] memory _array) public pure returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < _array.length; i++) {
            sum += _array[i];
        }
        return sum;
    }

    /**
    创建一个函数，删除数组中的特定元素并调整数组长度
    */
    function removeElement(
        uint[] memory _array,
        uint _index
    ) public pure returns (uint[] memory) {
        require(_index < _array.length, "index error");
        uint[] memory newArray = new uint[](_array.length - 1);
        for (uint i = 0; i < _array.length; i++) {
            if (i < _index) {
                newArray[i] = _array[i];
            } else if (i > _index) {
                newArray[i - 1] = _array[i];
            }
        }
        return newArray;
    }
}
