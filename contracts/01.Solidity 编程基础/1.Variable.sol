// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
 *solidity中的变量
 *1、状态变量（变量值永久保存在合约存储空间中的变量）
 *2、局部变量（变量值仅在函数执行过程中有效的变量，函数退出后，变量无效）
 *3、全局变量（保存在全局命名空间，用于获取区块链相关信息的特殊变量）
 */
contract Variable {
    uint public storeData; //状态变量
    constructor() {
        storeData = 10; //使用状态变量
    }

    /**
     *局部变量
     */
    function getData() public pure returns (uint) {
        uint a = 1;
        uint b = 2;
        uint c = a + b; //使用局部变量
        return c;
    }
    /**
     *全局变量
     */
    function getBlockData() public view returns (uint) {
        return block.timestamp; //使用全局变量 当前区块的时间戳，为 unix 纪元以来的秒
    }
    function getBlockNumber() public view returns (uint) {
        return block.number; //使用全局变量 当前区块的 number
    }
    function getBlockGaslimit() public view returns (uint) {
        return block.gaslimit; //使用全局变量 当前区块的 gaslimit
    }
    function getBlockCoinbase() public view returns (address) {
        return block.coinbase; //使用全局变量 当前区块矿工的地址
    }

    function getBlockDifficult() public view returns (uint) {
        return block.prevrandao; //随机数
    }
    function getGasLeft() public view returns (uint) {
        return gasleft(); //剩余 gas
    }

    function getBlockDatas() public pure  returns (bytes memory) {
        return msg.data;//调用当前函数的完整输入数据（以字节码形式存在），其存储位置是 calldata（只读的外部输入数据，不占用合约存储）
    }

    function getMessageSender() public view  returns (address){
        return msg.sender;//消息发送者 (当前 caller)
    }

    function getMessageSig() public pure   returns(bytes4){
        return msg.sig;//仅在函数调用时有效,返回当前调用的函数选择器
    }

    function getMessageValue() public payable  returns(uint) {
        return msg.value;// 是调用函数时附带的 ETH 数量（单位为 wei）
    }

    function getTxGasPrice () public view returns(uint){
        return tx.gasprice;//当前交易的 gas 价格
    }

    function getTxOrigin() public view returns(address){
        return tx.origin;//返回交易的原始发起地址
    }
}
