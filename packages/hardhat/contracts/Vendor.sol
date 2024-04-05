pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {YourToken} from "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    uint256 public constant tokensPerEth = 100;

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    // Receive ETH
    // Send Tokens to the buyer
    function buyTokens() public payable {
        uint256 amountToBuy = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, amountToBuy);
        emit BuyTokens(msg.sender, msg.value, amountToBuy);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public {
        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to Withdraw");

        require(msg.sender == owner(), "Only the owner can withdraw");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        uint256 ethToSend = _amount / tokensPerEth;
        console.log("ETH to SEND: ", ethToSend);

        // Receiving ETH
        (bool sent,) = msg.sender.call{value: ethToSend}("");
        require(sent, "Failed to sell tokens");

        // Sending tokens to contract
        bool success = yourToken.transferFrom(msg.sender, address(this), _amount);

        console.log(success);
        console.log(address(this));

        emit BuyTokens(address(this), _amount, ethToSend);
    }
}
