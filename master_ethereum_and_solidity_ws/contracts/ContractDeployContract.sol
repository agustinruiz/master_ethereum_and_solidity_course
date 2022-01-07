//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract A {
    address public ownerA;

    constructor(address eoa) {
        ownerA = eoa;
    }
}

contract Creator {
    address public ownerCreator;
    // Dynamic array that tontain the addresses of the new deployed contracts
    A[] public deployedA;

    constructor() {
        ownerCreator = msg.sender;
    }

    function deployA() public {
        // Creating an instance of A
        A new_A_address = new A(msg.sender); // This is the way to deploy a new contract A from the contract Creator
        // saving the address of the new contract in the array
        deployedA.push(new_A_address);
    }
}
