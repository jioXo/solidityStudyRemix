// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**
定义: Solidity 中使用 contract 关键字定义合约，类似于其他编程语言中的类。
*/
contract Hello {
    function sayHi() public {
        // 合约中的成员函数
    }
    /**
    在合约内部可以使用 this 关键字表示当前合约
    */
    function getAddress() public view returns (address) {
        return address(this); // 返回当前合约的地址
    }

    function destroyContract(address payable recipient) public {
        selfdestruct(recipient); // 销毁合约并发送以太币
    }

    // 可支付回退函数
    receive() external payable {}
}

/**
说明:
type(Hello).name: 获取合约的名字。
type(Hello).creationCode: 获取创建合约的字节码。
type(Hello).runtimeCode: 获取合约运行时的字节码。
*/
contract HelloType {
    function getContractInfo()
        public
        pure
        returns (string memory, bytes memory, bytes memory)
    {
        return (
            type(Hello).name,
            type(Hello).creationCode,
            type(Hello).runtimeCode
        );
    }

    /**
    使用 EVM 操作码 EXTCODESIZE:
    说明: 通过 extcodesize 操作码判断一个地址是否为合约地址。
    */
    function isContract(address addr) public  view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        } // 获取地址的代码大小
        return size > 0; // 大于 0 说明是合约地址
    }
}
