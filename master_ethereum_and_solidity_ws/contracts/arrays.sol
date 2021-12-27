// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FixedSizeArray{
    uint[3] public numbers = [2,3,4];

    // Tipos de datos bytes
    bytes1 public b1; //** byte es un alias de bytes1 en codigo viejo.
    bytes2 public b2;
    bytes3 public b3;
    // ... up to bytes32

    function setElement(uint index, uint value) public{
        numbers[index] = value;
    }

    function getLength() public view returns(uint){
        return numbers.length;
    }

    function setByteArray() public{
        b1 = 'a';
        b2 = 'ab';
        b3 = 'z';
    }
}