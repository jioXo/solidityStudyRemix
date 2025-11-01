// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
构造函数的继承
子合约继承父合约时，父合约的构造函数会被编译器拷贝到子合约的构造函数中执行

抽象合约的概念
如果一个合约中有未实现的函数，该合约必须标记为 abstract，这种合约不能部署。
抽象合约通常用作父合约。
*/
abstract contract A {
    uint public a;

    constructor(uint _a) {
        a = _a;
    }
}

//在继承列表中指定参数
// contract B is A(1) {
//     uint public b;

//     constructor() {
//         b = 2;
//     }
// }

//在子合约构造函数中通过修饰符调用父合约
contract B is A {
    uint public b;

    constructor() A(1) {
        b = 2;
    }
}