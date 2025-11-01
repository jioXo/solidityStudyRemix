// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract Block {
    //返回指定区块的哈希值
    function getBlockHash(uint _blockNumber) public view returns (bytes32) {
        return blockhash(_blockNumber);
    }

    //返回挖出当前区块的矿工地址
    function getCoinbase() public view returns (address) {
        return block.coinbase;
    }

    //返回当前区块的难度。
    function getDifficulty() public view returns (uint) {
        return block.prevrandao;
    }

    //返回当前区块的 Gas 上限
    function getGasLimit() public view returns (uint) {
        return block.gaslimit;
    }

    //返回当前区块号
    function getBlockNumber() public view returns (uint) {
        return block.number;
    }

    //返回当前区块的时间戳（单位：秒）。常用于时间条件判断。
    function getTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    //返回当前合约执行剩余的 Gas 数量。
    function getGasLeft() public view    returns (uint) {
        return gasleft();
    }

    //返回当前调用的完整 calldata
    function getCalldata() public pure  returns (bytes memory) {
        return msg.data;
    }

    //返回当前调用的发送者地址
    function getSendAddress() public view returns (address) {
        return  msg.sender;
    }

    //返回当前调用的函数选择器
    function getFunctionSelector() public pure returns (bytes4) {
        return msg.sig;
    }

    //返回此次调用发送的以太币数量（单位：wei）
    function getValue() public   payable   returns (uint) {
        return msg.value;
    }

    //返回当前交易的 Gas 价格
    function getGasPrice() public view returns (uint) {
        return tx.gasprice;
    }

    //返回交易的最初发起者地址。如果只有一个调用，tx.origin 与 msg.sender 相同；否则，tx.origin 始终是最初的交易发起者。
    function getTxOrigin() public view returns (address) {
        return tx.origin;
    }

}
