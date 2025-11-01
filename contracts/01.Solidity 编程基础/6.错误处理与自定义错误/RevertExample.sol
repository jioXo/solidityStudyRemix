// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
revert() 和 **revert(string memory reason)**函数可以用于立即停止执行并回滚状态。这通常用于在遇到某些无法满足的条件时终止函数
*/
contract RevertExample {
    function checkValue(uint value) public pure {
        if (value > 10) {
            revert("Value cannot exceed 10"); // 返回自定义错误信息
        }
    }
}