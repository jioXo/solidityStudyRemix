// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
构造函数的继承
子合约继承父合约时，父合约的构造函数会被编译器拷贝到子合约的构造函数中执行
*/
contract A {
    uint public a;

    constructor() {
        a = 1;
    }
}

contract B is A {
    uint public b;
    //父合约构造函数无参数的情况
    constructor() {
        b = 2;
    }
}