// SPDX-License-Identifier: GPL-3.0

//pragma solidity >=0.7.0 <0.9.0;
//pragma solidity 0.5.0; // para probar la vulnerabilidad de overflow
pragma solidity ^0.8.0;

contract Property{

    // 1. Boolean type
    bool public sold;

    // 2. Integer Type
    uint8 public x = 255;
    int8 public y = -10;

    // 3. overflow vulnerability
    function f1() public{
        x += 1;
    }
}