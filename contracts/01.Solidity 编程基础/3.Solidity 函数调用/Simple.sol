// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Simple {
    /**
    参数声明：
    函数参数与变量声明类似，输入参数用于接收调用时传入的值，输出参数用于返回结果。
    未使用的参数可以省略其名称。
    */
    function taker(uint _a, uint _b) public pure {
        // 使用 _a 和 _b 进行运算
    }

    /**
    返回值：
    ◦ Solidity 函数可以返回多个值，这通过元组（tuple）来实现。
    ◦ 返回值可以通过两种方式指定：
    ◦ 使用返回变量名：
    */
    function arithmetic(
        uint _a,
        uint _b
    ) public pure returns (uint o_sum, uint o_product) {
        o_sum = _a + _b;
        o_product = _a * _b;
    }

    /**
    直接在return语句中提供返回值：
    */
    function arithmetic2(
        uint _a,
        uint _b
    ) public pure returns (uint o_sum, uint o_product) {
        return (_a + _b, _a * _b);
    }

    function f() public pure returns (uint, bool, uint) {
        return (7, true, 2);
    }

    /**
    元组与多值返回：
    Solidity 支持通过元组返回多个值，并且可以同时将这些值赋给多个变量。
    示例代码：
    */
    function g() public pure  returns(uint , bool , uint ){
        (uint x, bool b, uint y) = f(); // 多值赋值
        return ( x,  b,  y);
    }
}

/**

Solidity中的函数可见性修饰符有四种，决定了函数在何处可以被访问：

private （私有）：
只能在定义该函数的合约内部调用。
internal （内部）：
可在定义该函数的合约内部调用，也可从继承该合约的子合约中调用。
external （外部）：
只能从合约外部调用。如果需要从合约内部调用，必须使用this关键字。
public （公开）：
可以从任何地方调用，包括合约内部、继承合约和合约外部。
*/
contract VisibilityExample {
    function privateFunction() private pure returns (string memory) {
        return "Private";
    }
    
    function internalFunction() internal pure returns (string memory) {
        return "Internal";
    }
    
    function externalFunction() external pure returns (string memory) {
        return "External";
    }
    
    function publicFunction() public pure returns (string memory) {
        return "Public";
    }

    /**
     * 由于privateFunction是私有函数，所以在合约外部无法直接调用它
     * 但是可以通过publicFunction来间接调用privateFunction
    */
    function testPrivateFunction() public pure returns(string memory){
            return privateFunction();
    }

    /**
     * 由于internalFunction是内部函数，所以在合约外部无法直接调用它
     * 但是可以通过publicFunction来间接调用internalFunction
    */
    function testInternalFunction() public  pure returns(string memory){
        return internalFunction();
    }

    /**
     * 由于externalFunction是外部函数，所以在合约外部无法直接调用它
     * 但是可以通过publicFunction来间接调用externalFunction
    */
    function testExternalFunction() public view  returns(string memory){
        return this.externalFunction();
    }
}

/**
状态可变性修饰符：
Solidity 中有三种状态可变性修饰符，用于描述函数是否会修改区块链上的状态：
view：
声明函数只能读取状态变量，不能修改状态。
pure：
声明函数既不能读取也不能修改状态变量，通常用于执行纯计算。
payable：
声明函数可以接受以太币，如果没有该修饰符，函数将拒绝任何发送到它的以太币。
*/
contract SimpleStorage {
    uint256 private data;

    function setData(uint256 _data) external {
        data = _data;  // 修改状态变量
    }

    function getData() external view returns (uint256) {
        return data;  // 读取状态变量
    }

    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;  // 纯计算函数
    }

    function deposit() external payable {
        // 接收以太币
    }
}