// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract Car {
    uint public  speed;

    function drive() public virtual {
            speed = 10;
    }

    // 父合约中获取 speed
    function getCarSpeed() public view returns (uint) {
        return speed;
    }
}

contract ElectricCar is Car{
    uint public  batteryLevel;

    function drive() public override  {
        super.drive();
        speed=9;
        batteryLevel = speed - 1;
    }

      // 子合约中获取 speed
    function getElectricCarSpeed() public view returns (uint) {
        return speed;
    }
}