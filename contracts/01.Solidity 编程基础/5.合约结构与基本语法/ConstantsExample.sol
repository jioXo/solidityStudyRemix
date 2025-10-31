// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
常量状态变量（constant）：
编译时常量，编译器会在编译时用值替换变量。
*/
contract ConstantsExample {
    uint public constant x = 42;

    function fun1() public {
        // x=10;//常量不可以修改
    }
}

/**
不可变量（immutable）：
在部署时确定，通常在构造函数中赋值，赋值后不可更改。
*/
contract ImmutableExample {
    uint public immutable maxBalance;

    constructor(uint _maxBalance) {
        maxBalance = _maxBalance;
    }
    function fun1() public {
        //maxBalance=10;//不可变量不可以修改
    }
}

/**
视图函数（view）：
声明不修改状态的函数，可读取状态变量。
*/
contract ViewFunctionExample {
    uint public data;

    function getData() public view returns (uint) {
        return data;
    }
}

/**
纯函数（pure）：
既不读取也不修改状态，仅依赖于函数参数。
*/
contract PureFunctionExample {
    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }
}
