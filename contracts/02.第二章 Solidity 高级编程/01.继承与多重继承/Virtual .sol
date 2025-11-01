// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
函数重写的概念
父合约中的虚函数（使用 virtual 关键字修饰）可以在子合约中被重写。重写的函数必须使用 override 关键字。
*/
contract Base1 {
    function foo() virtual public returns(uint){
        return 2;
    }
}

contract Base2 {
    function foo() virtual public returns(uint){
        return 3;
    }
}

contract Inherited is Base1, Base2 {
    //当合约多重继承且通过 super 调用父函数时，实际调用的是继承顺序中最后一个父合约的函数。
    function foo() public override(Base1, Base2) returns(uint){
        return  super.foo(); // 调用父合约的函数
    }
}