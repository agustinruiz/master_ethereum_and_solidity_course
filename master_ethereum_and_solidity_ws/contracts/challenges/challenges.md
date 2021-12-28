Challenges - Solidity Programming
Disclaimer: Use only the Rinkeby Testnet and Fake (Rinkeby) ETH. Working with cryptocurrencies involves lots of risks and any decision regarding cryptocurrency usage, legal matters, investments, taxes, cryptocurrency mining, exchange usage, wallet usage, and so on is at your own risk and responsibility.

Challenge #1

Consider this Smart Contract.

Change the state variable name to be declared as a public constant.

Declare a setter and a getter function for the supply state variable.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #2

Consider the solution from the previous challenge.

Add a public state variable of type address called owner.

Declare the constructor and initialize all the state variables in the constructor. The owner should be initialized with the address of the account that deploys the contract.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #3

Consider this Smart Contract.

Modify the changeTokens() function in such a way that it changes the state variable called tokens.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #4

Consider this Smart Contract.

Add a function so that the contract can receive ETH by sending it directly to the contract address.

Return the contract’s balance.

Deploy and test the contract on Rinkeby Testnet.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #5

Consider the solution from the previous challenge.

Add a function that transfers the entire balance of the contract to another address.

Deploy and test the contract on Rinkeby Testnet.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #6

Consider the solution from the previous challenge.

Add a new immutable state variable called admin and initialize it with the address of the account that deploys the contract;

Add a restriction so that only the admin can transfer the balance of the contract to another address;

Deploy and test the contract on Rinkeby Testnet.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #7

Consider this smart contract.

Add a function called start() that adds the address of the account that calls it to the dynamic array called players.

Deploy and test the contract on Rinkeby Testnet.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #8

Consider this smart contract.

Change the visibility specifier of f() so that it can be called from derived contracts as well. Do not set it as being public.

Create a new contract that derives from A and call f() from the new contract.

Are you stuck? Do you want to see the solution to this challenge? Click here.

Challenge #9

Declare a function that concatenates two strings.

Note: Since Solidity does not offer a native way to concatenate strings use abi.encodePacked() to do that. Read the official doc for examples.

Are you stuck? Do you want to see the solution to this challenge? Click here.
