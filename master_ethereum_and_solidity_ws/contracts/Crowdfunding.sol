//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

/*
The CrowdFunding Contract - Planning and Design
● The Admin will start a campaign for CrowdFunding with a specific monetary goal and deadline.
● Contributors will contribute to that project by sending ETH.
● The admin has to create a Spending Request to spend money for the campaign.
● Once the spending request was created, the Contributors can start voting for that specific Spending Request.
● If more than 50% of the total contributors voted for that request, then the admin would have the permission to spend the amount specified in the spending request.
● The power is moved from the campaign’s admin to those that donated money.
● The contributors can request a refund if the monetary goal was not reached within the deadline.
*/

contract CrowdFunding {
    // To save the contributors and the money they contribute
    mapping(address => uint256) public contributors;
    // To save the administrator of the campaign
    address public admin;
    // the number the contributors
    uint256 public numOfContributors;
    // minimun contribution, deadline and the goal
    uint256 public minimumContribution;
    uint256 public deadline; // timestamp
    uint256 public goal;
    // the total rised amount
    uint256 public raisedAmount;

    // Constructor. Arguments: the goal amount, the time that the crowdfunding will be active IN SECONDS.
    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        deadline = block.timestamp + _deadline; // block.timestamp gives me the time of the current block in seconds.
        minimumContribution = 100;
        admin = msg.sender;
    }

    function contribute() public payable {
        require(block.timestamp <= deadline, "Deadline has passed!");
        require(
            msg.value >= minimumContribution,
            "Minimum contribution not met!"
        );

        if (contributors[msg.sender] == 0) {
            // If the contributor doesn't contribute yet:
            numOfContributors++;
        }

        contributors[msg.sender] += msg.value;

        raisedAmount += msg.value;
    }

    // para enviar fondos directamente a la direcicon del contrato, tenemos que declarar la funcion recieve
    receive() external payable {
        contribute();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getRefound() public {
        // A contributer will be allowed to get a refound if two conditions are met:
        // The deadline of th campaign has passed and the goal was not reached
        require(block.timestamp > deadline && raisedAmount < goal);
        // Only a contributer can call this function to get a refound.
        require(contributors[msg.sender] > 0);

        // to be more clarify
        address payable recipient = payable(msg.sender);
        uint256 value = contributors[msg.sender];
        recipient.transfer(value);

        // we could replace the previous 3 lines with:
        //   payable(msg.sender).transfer(contributors[msg.sender]);

        contributors[msg.sender] = 0;
    }
}
