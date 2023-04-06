// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract Migrations {
    address public owner;                          // Owner of the contract
    uint public last_completed_migration;         // Last completed migration step

    constructor() public {
        owner = msg.sender;                       // Set the contract deployer as the owner
    }

    modifier restricted() {
        require(msg.sender == owner, "Restricted");  // Restrict access to only the contract owner
        _;                                         // Continue with the function execution
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;     // Set the last completed migration step
    }

    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address); // Create a new instance of the contract at the new address
        upgraded.setCompleted(last_completed_migration); // Call the setCompleted function of the upgraded contract
    }
}
