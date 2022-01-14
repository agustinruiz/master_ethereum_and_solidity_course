//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

abstract contract BaseContract {
    int256 public x;
    address public owner;

    constructor() {
        x = 5;
        owner = msg.sender;
    }

    function setX(int256 _x) public {
        x = _x;
    }

    function resetX() public virtual;
}

contract A is BaseContract {
    int256 public y = 3;

    function resetX() public override {
        x = 0;
    }
}
