// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
Gas 消耗：

assert 失败时会消耗掉所有的剩余 Gas，而 require 则会返还剩余的 Gas 给调用者。
适用场景：

assert：用于检查合约内部逻辑的错误或不应该发生的情况，通常在函数末尾或状态更改之后使用。
require：用于检查输入参数、外部调用返回值等，通常在函数开头使用。
操作符不同：

assert 失败时执行无效操作（操作码 0xfe），require 失败时则执行回退操作（操作码 0xfd）。
*/
contract AssertRequireExample {
    address public owner;
    constructor()  {
        owner = msg.sender;
    }
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only the owner can transfer ownership."); // 检查调用者是否为合约所有者
        owner = newOwner;
    }
    function checkBalance(uint a, uint b) public pure returns (uint) {
        uint result = a + b;
        assert(result >= a); // 检查溢出错误
        return result;
    }
}