//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

//abstract contract BaseContract {
interface BaseContract {
    //    int256 public x;
    //    address public owner;

    //    constructor() {
    //        x = 5;
    //        owner = msg.sender;
    //    }

    //    function setX(int256 _x) public {
    //        x = _x;
    //    }
    function setX(int256 _x) external;

    //    function resetX() public virtual;
    function resetX() external;
}

contract A is BaseContract {
    int256 public x; // this is because base contract is an interface that dont declare x

    int256 public y = 3;

    // this is because base contract is an interface that dont declare setX
    function setX(int256 _x) public override {
        x = _x;
    }

    function resetX() public override {
        x = 0;
    }
}
