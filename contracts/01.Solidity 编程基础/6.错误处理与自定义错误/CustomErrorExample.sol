// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
在 Solidity 0.8.0 之后，Solidity 引入了自定义错误机制（custom errors），提供了一种更加 Gas 高效的错误处理方式。
自定义错误比 require 或 revert 的字符串消息消耗更少的 Gas，因为自定义错误只传递函数选择器和参数。
自定义错误的优势：
自定义错误不会在错误消息中传递冗长的字符串，因此相比传统的 require 和 revert，节省了更多的 Gas。
*/
contract CustomErrorExample {
    error Unauthorized(address caller);  // 自定义错误
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    function restrictedFunction() public view  {
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);  // 使用自定义错误
        }
    }
}