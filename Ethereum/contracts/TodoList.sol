// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// Contract to manage a TodoList
contract TodoList {
    uint public taskCount = 0; // Count of tasks

    // Struct to represent a task
    struct Task {
        uint id;
        string content;
        bool completed;
    }

    mapping(uint => Task) public tasks; // Mapping to store tasks

    event TaskCreated(uint id, string content, bool completed);

    event TaskCompleted(uint id, bool completed);

    constructor() public {
        createTask("Check out The Tasks You Want "); // Constructor to create a default task during contract deployment
    }

    // Function to create a new task
    function createTask(string memory _content) public {
        taskCount++; // Increment task count
        tasks[taskCount] = Task(taskCount, _content, false); // Add new task to mapping
        emit TaskCreated(taskCount, _content, false); // Emit event for task creation
    }

    // Function to toggle the completion status of a task
    function toggleCompleted(uint _id) public {
        Task memory _task = tasks[_id]; // Get the task from mapping
        _task.completed = !_task.completed; // Toggle completion status
        tasks[_id] = _task; // Update the task in mapping
        emit TaskCompleted(_id, _task.completed); // Emit event for task completion status change
    }
}
