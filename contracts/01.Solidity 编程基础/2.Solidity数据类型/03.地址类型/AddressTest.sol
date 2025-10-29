// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
/**
address 类型
定义: address 是一个 20 字节（160 位）的值，代表以太坊区块链上的一个账户地址。
*/
contract AddressTest {
    constructor() payable {}
    //定义地址
    address public myAddress = 0x1234567890123456789012345628901234567890;
    address myAddress2 = msg.sender; // 当前合约调用者的地址

    //address的应用场景：白名单
    mapping(address => bool) public whiteList;

    function getMyAdderss() public returns (address) {
        myAddress = 0x1234567890123456789012345628901234567890;
        return myAddress;
    }

    /**
    说明: 使用 balance 属性获取地址的以太坊余额（单位为 wei）
    */
    function getAddressBlance() public view returns (uint, uint) {
        return (myAddress.balance, myAddress2.balance);
    }

    /**
    transfer():
    说明: 使用 transfer() 方法将以太币转移到另一个地址，推荐使用这种方法。
    address 和 address payable 的区别：address payable 是可以接收以太币的地址类型。address 类型不能直接发送以太币，必须显式转换为 address payable
    */
    function transferTest() public {
        address payable recipient = payable(myAddress);
        recipient.transfer(1 ether); //recipient为接收eth的地址，转账路径是：合约=》recipient
    }

    /**
    send():
    说明: 使用 send() 方法转移以太币，返回布尔值表示转移是否成功。由于没有自动回退机制，不推荐使用
    */
    function sendTest() public {
        address payable recipient = payable(myAddress);
        bool success = recipient.send(1 ether); // 转移 1 ETH，返回成功与否
        require(success, "Transfer failed.");
    }

    /**
    call():
    说明: 使用 call() 进行低级别调用，讨论其安全性问题以及与 send() 和 transfer() 的区别。
    */
    function callTest() public {
        address payable recipient = payable(myAddress);
        (bool success, ) = recipient.call{value: 1 ether}("");
        require(success, unicode"转账失败");
    }

    //添加白名单
    function addWhiteList(address _whiteListAddress) public {
        whiteList[_whiteListAddress] = true;
    }

    //判断是否存在于白名单
    function isWhiteListed(
        address _whiteListAddress
    ) public view returns (bool) {
        return whiteList[_whiteListAddress];
    }

    //授权支付合约
    function pay(address payable recipient) public payable {
        require(whiteList[recipient], "Recipient is not whitelisted.");
        recipient.transfer(msg.value);
    }

    receive() external payable {}
}
