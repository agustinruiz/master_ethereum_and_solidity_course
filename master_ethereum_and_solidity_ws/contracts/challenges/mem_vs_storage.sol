//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract MyTokens {
    string[] public tokens = ["BTC", "ETH"];

    function changeTokens(uint256 i, string memory token) public {
        string[] memory t = tokens;
        t[i] = token;
        tokens = t;
    }
}
