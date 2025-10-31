// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
事件（Events）
事件用于与外部应用交互，通过事件通知外部发生的合约状态变化。
使用emit关键字触发事件。
*/
contract EventExample {
    event DataChanged(uint newValue);
    uint public data;
    function setData(uint _data) public {
        data = _data;
        emit DataChanged(_data);  // 触发事件
    }
}