// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Owned {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function setOwner(address _owner) public virtual {
        owner = payable(_owner);
    }
}

contract Mortal is Owned {
    /*
    继承的特点
    子合约可以访问父合约中的非私有成员。
    子合约不能再次声明已经在父合约中存在的状态变量。
    子合约可以通过重写函数改变父合约的行为。
    */
    event SetOwner(address indexed owner);

    function setOwner(address _owner) public override {
        super.setOwner(_owner); // 调用父合约的 setOwner
        emit SetOwner(_owner);
    }
}
