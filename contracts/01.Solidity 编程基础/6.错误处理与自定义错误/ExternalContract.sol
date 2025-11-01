// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ExternalContract {
    function getValue() public pure returns (uint) {
        return 42;
    }
    function willRevert() public pure {
        revert("This function always fails");
    }
}
contract TryCatchExample {
    ExternalContract externalContract;
    constructor() {
        externalContract = new ExternalContract();
    }
    function tryCatchTest() public view returns (uint, string memory) {
        try externalContract.getValue() returns (uint value) {
            return (value, "Success");
        } catch {
            return (0, "Failed");
        }
    }
    function tryCatchWithRevert() public view  returns (string memory) {
        try externalContract.willRevert() {
            return "This will not execute";
        } catch Error(string memory reason) {
            return reason;  // 捕获错误信息
        } catch {
            return "Unknown error";
        }
    }
}