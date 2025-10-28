// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
int/uint 表示有符号和无符号的整数
关键字 int/uint 的末尾接上一个数字表示数据类型所占用空间的大小，这个数字是以 8 的倍数，最高为 256，
因此，表示不同空间大小的整型有：uint8、uint16、uint32 ... uint256，int 同理，无数字时 uint 和 int 对应 uint256 和 int56
因此整数的取值范围跟不同空间大小有关， 比如 uint32 类型的取值范围是 0 到 2^32-1(2 的 32 次方减 1)
*/
contract IntegerType {
    int8 a = -1;
    int16 b = 2;
    uint32 c = 10;
    uint8 d = 16;
    function add(uint x, uint y) public pure returns (uint z) {
        z = x + y;
    }
    function divide(uint x, uint y) public pure returns (uint z) {
        z = x / y;
    }
    function leftshift(int x, uint y) public pure returns (int z) {
        z = x << y; //x << y 和 x * (2**y)
    }
    function rightshift(int x, uint y) public pure returns (int z) {
        z = x >> y; //x >> y 和 x / (2*y)
    }
    function testPlusPlus() public pure returns (uint) {
        uint x = 1;
        uint y = ++x; // c = ++a;
        return y;
    }
    function add1() public pure returns (uint8) {
        uint8 x = 128;
        uint8 y = x * 2;
        return y;
    }
    function add2() public pure returns (uint8) {
        uint8 i = 240;
        uint8 j = 16;
        uint8 k = i + j;
    }
    function sub1() public pure returns (uint8) {
        uint8 m = 1;
        uint8 n = m - 2;
        return n;
    }
}
