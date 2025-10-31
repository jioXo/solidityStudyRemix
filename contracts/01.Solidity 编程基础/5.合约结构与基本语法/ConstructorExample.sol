// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
构造函数（Constructor）
构造函数使用 constructor 关键字声明，在合约部署时执行。用于初始化合约状态。
示例代码：
*/
contract ConstructorExample {
    uint public x; // 状态变量
    address public owner; // 状态变量
    constructor() { // 构造函数
        x = 10; // 初始化状态变量
        owner = msg.sender; // 初始化状态变量
    }
}