// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
函数类型
*/
contract FunSelecter {

    /**
    Solidity 内置获取选择器的方法
    */
    function fun1() public pure returns (bytes4) {
        bytes4 selector = this.func.selector;
        return selector;
    }

    /*
    函数选择器是通过对函数签名（函数名及其参数类型）进行 Keccak256 哈希计算，并截取前 4 个字节生成的唯一标识符。它用于识别和调用特定函数。
    */
    function fun2() public  pure returns (bytes4){
       bytes4 selector= bytes4(keccak256("func(uint256)"));
       return selector;
    }

    function func(uint a) external pure  returns (uint){
        return a;
    }


    /**
     通过函数选择器调用函数
    */
    function select(bytes4 _selector,uint x) external returns(uint z){
        (bool success, bytes memory data) =address(this).call(abi.encodeWithSelector(_selector, x));
        require(success, "call failed");
        z = abi.decode(data, (uint));
    }
}