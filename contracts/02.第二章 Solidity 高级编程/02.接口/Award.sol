// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IToken.sol";
contract Award {
    IToken immutable token;
    // 构造函数中传入 SimpleToken 合约的地址
    constructor(IToken _token) {
        token = _token;
    }
    // 调用 SimpleToken 合约的 transfer 函数来发送奖励
    function sendBonus(address user) public {
        token.transfer(user, 100);  // 向用户发送100个代币作为奖励
    }
}