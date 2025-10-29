// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
练习任务:

编写一个智能合约，允许用户存款并设置一个特定的地址为白名单地址，只有该地址能够提取合约中的资金。
实现一个功能，允许用户查询自己在合约中的余额，并且测试存款、提取和余额查询功能的正确性。
*/
contract AddressTest{
    //白名单地址
    address public whitleAddress;
    //存款人和地址余额
    mapping(address=>uint) public blance;

    constructor() {
        whitleAddress=msg.sender;
    }

    //存款
    function deposit() public payable{
        blance[msg.sender] +=msg.value;
    }

    //查询余额
    function checkBlance() public view returns(uint){
        return blance[msg.sender];
    }

    //提取金额：白名单地址才能提取
    function withdraw(uint amount) public {
        require(msg.sender==whitleAddress,"noly whitleAddress can withdraw!");
        //先改状态再转账，防止重入攻击
        blance[msg.sender] -=amount;
        payable(msg.sender).transfer(amount);
    }

}