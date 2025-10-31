// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
应用场景对比
使用 receive 函数的场景：

合约需要接收纯以太币转账且没有任何调用数据。
想要避免合约被错误调用时触发 fallback 逻辑，只处理纯以太币转账。
使用 fallback 函数的场景：

处理错误的函数调用。
当合约需要处理带数据的以太币转账或调用不存在的函数。
*/
contract ReceiveExample {
    address owner;

    constructor() {
        owner=msg.sender;
    }

    event Received(address sender, uint amount);
    // 仅用于接收以太币
    receive() external payable{
        //记录事件
        emit Received(msg.sender,msg.value);
    }

    function sendEth() public payable returns(bool){
        address contractAddress=address(this);
        (bool success, )=contractAddress.call{value:msg.value}("");
        return success;
    }
}


contract FallbackExample {
    event FallbackCalled(address sender, uint amount);
    // 当调用不存在的函数时触发
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value);
    }
}

contract MixedExample {
    event Received(address sender, uint amount);
    event FallbackCalled(address sender, uint amount);
    // 当纯以太币转账时触发
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // 当调用不存在的函数或附加了数据时触发
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value);
    }
}