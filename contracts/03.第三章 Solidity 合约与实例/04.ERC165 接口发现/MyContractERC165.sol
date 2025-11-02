// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// 定义自定义接口
interface IMyInterface {
    function myFunction() external returns(bytes4);
    function anotherFunction(uint256) external returns (bool);
}

contract MyContractERC165 is ERC165, IMyInterface {
    // 实现自定义接口的函数
    function myFunction() external override returns(bytes4){
        return msg.sig;
    }
    function anotherFunction(uint256) external pure  override returns (bool) {
        return true;
    }

    // 重写 supportsInterface，声明支持的接口
    function supportsInterface(bytes4 interfaceId) public view  override(ERC165) returns (bool) {
        // 支持 ERC165 自身 + 自定义接口 IMyInterface
        return 
            interfaceId == type(IERC165).interfaceId || 
            interfaceId == type(IMyInterface).interfaceId;
    }
}


contract CheckInterface {
    // 目标合约地址和接口 ID
    address public targetContract;
    bytes4 public myInterfaceId = type(IMyInterface).interfaceId;

    constructor(address _target) {
        targetContract = _target;
    }

    // 检查目标合约是否支持 IMyInterface
    function checkSupport() external view returns (bool) {
        // 调用目标合约的 supportsInterface 函数
        return IERC165(targetContract).supportsInterface(myInterfaceId);
    }
}