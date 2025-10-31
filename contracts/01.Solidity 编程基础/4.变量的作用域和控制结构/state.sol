// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract C {
    uint public data = 30; // 公共状态变量
    uint internal iData = 10; // 内部状态变量
    uint private pData = 20; // 私有状态变量
    function x() public returns (uint) {
        data = 3; // 内部访问公共变量
        return data;
    }
    function internalDate() public returns (uint) {
        iData = 3; // 内部访问内部变量
        return iData;
    }
    function z() public returns (uint) {
        pData = 3; // 内部访问私有变量
        return pData;
    }
}
contract Caller {
    C c = new C();
    function f() public view returns (uint) {
        return c.data(); // 外部访问公共变量
    }
    function g() public  returns (uint) {
        // return c.iData(); // 无法访问内部变量
        // return c.pData(); // 无法访问私有变量
        return c.x();
    }
}
contract D is C {
    uint storedData;
    function y() public returns (uint) {
        iData = 3; // 派生合约内部访问内部变量
        return iData;
    }
    function getResult() public view returns (uint) {
        return storedData; // 访问状态变量
    }
}
