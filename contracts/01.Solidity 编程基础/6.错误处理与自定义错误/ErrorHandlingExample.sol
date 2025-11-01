// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ErrorHandlingExample {
    uint public balance;
    function sendHalf(address addr) public payable {
        require(msg.value % 2 == 0, "Even value required."); // 输入检查
        uint balanceBeforeTransfer = address(this).balance;
        payable(addr).transfer(msg.value / 2);
        assert(address(this).balance == balanceBeforeTransfer - msg.value / 2); // 内部错误检查
    }
}
