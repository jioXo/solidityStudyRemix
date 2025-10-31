// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
函数修改器（Modifiers）
函数修改器用于改变函数的行为，可以用于验证条件、修改参数等。
*/
contract ModifierExample {
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function.");
        _; // 表示执行函数体
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
