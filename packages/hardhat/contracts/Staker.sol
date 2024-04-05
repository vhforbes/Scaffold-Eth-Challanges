// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    uint256 public threshold = 1 ether;
    uint256 public deadline = block.timestamp + 30 seconds;
    bool public openForWithdraw = false;

    mapping(address => uint256) public balances;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    event Stake(address sender, uint256 ammount);

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    function execute() public {
        require(block.timestamp > deadline, "You need to wait the deadline!");

        if (address(this).balance > threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (deadline <= block.timestamp) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function withdraw() public {
        uint256 addressBalance = balances[msg.sender];
        (bool sent,) = msg.sender.call{value: addressBalance}("");
        balances[msg.sender] -= addressBalance;
        require(sent, "Failed to withdraw");
        require(openForWithdraw, "Withdraw is closed");
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
