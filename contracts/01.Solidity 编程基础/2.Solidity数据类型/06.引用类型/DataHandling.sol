// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract DataHandling {
    uint[] data;

    /**
    收一个 memory 数组并将其内容复制到 data 中
    */
    function updateData(uint[] memory newData) public {
        data=newData;
    }

    /**
    返回 data 数组
    */
    function getData() public view returns(uint[] memory) {
        return data;
    }

    /**
    修改 data 数组中指定索引位置的值
    */
    function modifyStorageData(uint index, uint value) public {
        data[index]=value;
    }

    /**
    尝试修改传入的 memory 数组，并返回修改后的数组
    memory 数组长度固定，超界访问会触发异常
    storage 数组支持自动扩容，而你当前用的 memory 数组不支持自动扩容
    */
    function modifyMemoryData(uint[] memory memData) public pure  returns(uint[] memory){
        for(uint i=0;i<4;i++){
            memData[i]=i;
        }
        return memData;
    }
}


