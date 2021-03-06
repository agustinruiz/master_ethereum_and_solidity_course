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
    // When we declear a public state variable a getter function is automatically created. So that getter functions complete the contract functions.
    string public name = "Cryptos"; // Standar variable that contains the name
    string public symbol = "CRPT"; // Standar variable that contains the symbol of the coin
    uint256 public decimals = 0; // decimals. how divisible a token can be. 18 is the most used number.
    uint256 public override totalSupply; // number of tokens. the override keyword is necesary because in fact it creates a getter function called totalSupply.

    address public founder; // the address who deploys the contract and posess all the tokens.

    mapping(address => uint256) public balances; // the number of tokens of each address. The default value of any address will be 0

    mapping(address => mapping(address => uint256)) allowed; // The first address allowed the second to spend uint tokens

    // Example: 0x1111... (owner) allows 0x2222... (spender) to withraw 100 tokens
    // allowed[0x1111...][0x2222...] = 100;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens)
        public
        virtual
        override
        returns (bool success)
    {
        // Adding virtual keyword to override it on the ICO contract and add the locking feature
        // Virtual means that the function can change its behaiviour in derives contracts by overriding
        require(balances[msg.sender] >= tokens); // Check if the sender have enaugh tokens
        // Updating the balances
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        // sending the event
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    // function that returns the allowence of an address
    // allowence is the getter function of the allowed state variable
    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        // checking that the sender have enaugh tokens that he wants to allowed to spend
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;

        // Triggering the approve event
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    // NOTE: other implementatios defines increase approvals and decrease approvals functions. However there are not part of the ERC20 standard

    // transferFrom allows the spender to spend tokens of the owner multiple times until the total of tokens allowed
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual override returns (bool success) {
        // Adding virtual keyword to override it on the ICO contract and add the locking feature
        // Virtual means that the function can change its behaiviour in derives contracts by overriding
        // Check if the allowance of the current user is grater than or equal to the number of tokens he wants to transfer
        require(allowed[from][to] >= tokens);
        // Cheking that the balance of the owner is grater than o equals to the number of tokens to be transfer.
        require(balances[from] >= tokens);

        // updating the balances of the two users accordingly
        balances[from] -= tokens;
        balances[to] += tokens;

        allowed[from][to] -= tokens;

        return true;
    }
}

// The recommended aproach to create a ICO smart contract is to derive the contract from the ERC20 smart contract.
contract CryptosICO is Cryptos {
    // the admin that can stop the ICO if there is an emergency or can change the deposit address if it gets compromized
    address public admin;
    // the address that gets transfer to the ethers send to the contract.
    // The investors send eth to the contract address, the eth will be automatically transferred to the deposit address
    // and the cryptos will be added to the balance of the investors. Is safer than the storage the ether on the contract.
    address payable public deposit;

    // the token price
    uint256 tokenPrice = 0.001 ether; // 1 ETH = 1000 CRPT
    // maximum amount of ether
    uint256 public hardCap = 300 ether;
    // variable that holds the total amount of ether sent to the ICO
    uint256 public raisedAmount;
    // start of the ICO
    uint256 public saleStart = block.timestamp; // in this example the start time is the time when the contract is deplyed. right away.
    // If i have to start the ICO in one hour:
    // uint public saleStart = block.timestamp + 3600;
    // End of the ICO
    uint256 public saleEnd = block.timestamp + 604800; // the ICO ends in 1 week

    // It is common in an ICO to lock the tokens for an amount of time.
    // I want the tokens to be transferable only after a time after the ICO ends so that the early investors cannot dump
    // the tokens on the market causing the price to collapse.
    uint256 public tokenTradeStart = saleEnd + 604800; // tokens will be transferable in a week after sale ends

    // Maximum and minimum investment of an address
    uint256 public maxInvestment = 5 ether;
    uint256 public minInvestment = 0.1 ether;

    // The possible states of the ICO
    enum State {
        beforeStart,
        running,
        afterEnd,
        halted
    }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    // requirements of the ICO

    // the first requirement is that the admin coul stop the ICO in case of an emergency
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() public onlyAdmin {
        // To stop the ICO get compromized or something happend
        icoState = State.halted;
    }

    function resume() public onlyAdmin {
        // To resume after the problem was solved
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyAdmin {
        // To change the deposit address
        deposit = newDeposit;
    }

    function getCurrentState() public view returns (State) {
        // To get the current state
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < saleStart) {
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    // event to inform an invest
    event Invest(address investor, uint256 value, uint256 tokens);

    // Primary function of the smart contract
    function invest() public payable returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.running);

        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        // Calculating the number of tokens the nvestor will get for the ether he has just send
        uint256 tokens = msg.value / tokenPrice;

        // updating the tokens balances
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        // transfering the eth to the deposit address
        deposit.transfer(msg.value);
        // Finally i am emitting an event wich is a log message written to the blockchain that can be process by frontends.
        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }

    // To recieve invests when the investor sen eth directly to the contract i must declare the recieve function
    receive() external payable {
        invest();
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        // making the aditional chacks for the transfer
        require(block.timestamp > tokenTradeStart); // Check if the lockup period passed
        // Calling the original transfer function
        Cryptos.transfer(to, tokens);
        // another way to do it is:
        // super.transfer(to, tokens);
        return true;
    }

    // transferFrom allows the spender to spend tokens of the owner multiple times until the total of tokens allowed
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        // making the aditional chacks for the transfer
        require(block.timestamp > tokenTradeStart); // Check if the lockup period passed
        // Calling the original transfer function
        Cryptos.transferFrom(from, to, tokens);
        // another way to do it is:
        // super.transferFrom(from, to, tokens);
        return true;
    }

    // burning the tokens that cannot been sold.
    function burn() public returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        return true;
    }
}
