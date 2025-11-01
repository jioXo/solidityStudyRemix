// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
Solidity 中的接口具有以下限制：

无法继承其他合约或接口：接口不能扩展其他合约或接口。
无法定义构造函数：接口不允许定义任何构造函数，因为它不能有内部状态。
无法定义状态变量：接口不能有状态变量，因为它不存储数据。
无法定义结构体或枚举：接口不能包含结构体或枚举。
接口的语法
接口通过 interface 关键字定义，接口中的所有函数默认为 external，且不带实现。
*/
interface IToken {
    function transfer(address recipient, uint256 amount) external;
}



// 实现接口的合约
contract SimpleToken is IToken {
    mapping(address => uint256) public balances;
    constructor() {
        balances[msg.sender] = 1000;  // 初始化代币余额
    }
    // 实现接口中的 transfer 函数
    function transfer(address recipient, uint256 amount) public override {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}