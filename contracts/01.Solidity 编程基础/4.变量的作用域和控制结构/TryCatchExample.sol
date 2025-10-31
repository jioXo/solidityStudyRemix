// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract TryCatchExample {
    function tryCatchDemo(address _contractAddress) public pure  returns (bool){
        // 尝试调用外部合约的函数
        try ExternalContract(_contractAddress).someFunction() returns (bool) {
            // 处理成功
            return true;
        } catch {
            // 处理失败
            return false;
        }
    }
}
contract ExternalContract {
    function someFunction() public  pure returns   (bool) {
        // 这里可以是任何逻辑，例如抛出错误
        revert("Error occurred");
    }
}
