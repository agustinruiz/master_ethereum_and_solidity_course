//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------

interface ERC20Interface {
    // The first three are the mandatory functions
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract Cryptos is ERC20Interface {
    string public name = "Cryptos"; // Standar variable that contains the name
    string public symbol = "CRPT"; // Standar variable that contains the symbol of the coin
    uint256 public decimals = 0; // decimals. how divisible a token can be. 18 is the most used number.
    uint256 public override totalSupply; // number of tokens. the override keyword is necesary because in fact it creates a getter function called totalSupply.

    address public founder; // the address who deploys the contract and posess all the tokens.

    mapping(address => uint256) public balances; // the number of tokens of each address. The default value of any address will be 0
}
