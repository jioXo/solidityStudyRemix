// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract SelecterHomeWork {
    // 状态变量，用于存储函数选择器
    bytes4 storedSelector;

    /*
    计算平方
    */
    function square(uint x) public pure returns (uint) {
        return x*x;
    }

    /**
    计算两倍
    */
    function double(uint x) public  pure returns(uint){
        return 2*x;
    }

    /**
    根据传入的选择器动态调用 square 或 double
    */
    function executeFunction(bytes4 selector, uint x) public  pure returns(uint){
        if(selector==bytes4(keccak256("square(uint256)"))){
            return square(x);
        }else if(selector==bytes4(keccak256("double(uint256)"))){
            return double(x);
        }else{
            return 0;
        }
    }

    /**
    将选择器存储在状态变量
    */
    function storeSelector(bytes4 selector) public {
        storedSelector=selector;
    }

    /**
    调用存储在 storedSelector 中的函数，并返回结果
    */
    function executeStoredFunction(uint x) public returns(uint){
        //先判断是否有值
        require(storedSelector !=bytes4(0),"Selector not set");
       (bool success, bytes memory result)= address(this).call(abi.encodeWithSelector(storedSelector, x));
       require(success,"function call failed");
       return abi.decode(result, ( uint ));
    }
}