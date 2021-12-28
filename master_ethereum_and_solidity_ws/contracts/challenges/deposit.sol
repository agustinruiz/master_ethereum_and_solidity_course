//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Deposit {
    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function transferBalance(address payable recipient) public {
        uint256 balance = getBalance();
        recipient.transfer(balance);
    }
}
