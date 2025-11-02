// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract MyToken is ERC20 {
    // 构造函数：第一个参数是代币名称，第二个是代币符号
    constructor() ERC20("My Token", "MTK") {
        // 可选：如果需要初始化铸造代币，可在这里添加 mint 逻辑
        // 例如：铸造 1000 个代币给部署者
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function checkBalance(address account) public view returns (uint256) {
        return balanceOf(account); // 返回指定账户的代币余额
    }
}
