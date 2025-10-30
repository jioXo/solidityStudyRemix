// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
应用场景：
代币合约：使用映射存储账户余额。
游戏合约：使用映射存储玩家的等级或其他属性。

键类型的限制：
键类型不能是映射、变长数组、合约、枚举或结构体。
值类型的无限制：值类型可以是任何类型，包括映射类型。
没有长度和键集合/值集合的概念：
Solidity中的映射没有内建的键集合或值集合，也无法获取映射的长度。这与Java和Python中的映射结构不同。
删除操作的特殊性：
从映射中删除一个键的值，只需使用delete关键字，但键本身不会被移除，只是值被重置为默认值。
*/
contract MappingExample {
    mapping(address => uint) public balances;

    function update(uint newBalance) public {
        balances[msg.sender] = newBalance;
    }
}

contract MappingUser {
    function f() public returns (uint) {
        MappingExample m = new MappingExample();
        m.update(100);
        return m.balances(address(this));
    }
}