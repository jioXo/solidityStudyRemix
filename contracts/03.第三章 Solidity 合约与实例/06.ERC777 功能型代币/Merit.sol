// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
contract Merit is IERC777Recipient {
    //
    mapping(address => uint) public givers;
    address _owner;
    IERC777 _token;
    IERC1820Registry private _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;
    constructor(IERC777 token) {
        _erc1820.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
        _owner = msg.sender;
        _token = token;
    }
    function tokensReceived(
        address operator,
        address from,// 捐赠者的地址
        address to, // 接收者（这里是 Merit 合约自己）
        uint amount,// 捐赠的代币数量
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        // 核心逻辑：将捐赠者的累计积分增加本次捐赠数量
        givers[from] += amount;
    }
    // 功德箱管理员提取代币
    function withdraw() external {
        require(msg.sender == _owner, "no permission");
        uint balance = _token.balanceOf(address(this));
        _token.send(_owner, balance, "");
    }
}
