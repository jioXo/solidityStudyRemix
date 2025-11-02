// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library SafeMath {
    function add(uint a, uint b) external  pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}
// 使用 SafeMath 库的合约
contract AddTest {
    function add(uint x, uint y) public pure returns (uint) {
        return SafeMath.add(x, y);
    }
}