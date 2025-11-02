// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//0.8以后的版本已经不需要用safemath了，因为自带了整数溢出 / 下溢的检查机制
contract MyContract {
    using SafeMath for uint256;
    uint counter;
    function add(uint i) public {
        // 使用 SafeMath 的 add 方法
        counter = counter.add(i);
    }
}
