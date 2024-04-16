//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Balloons is ERC20 {
	event Approved(address approvedBy, address spender, uint256 amount);

	constructor() ERC20("Balloons", "BAL") {
		_mint(msg.sender, 1000 ether); // mints 1000 balloons!
	}

	function approve(
		address spender,
		uint256 amount
	) public override returns (bool) {
		bool approvedSuccess = super.approve(spender, amount);

		if (approvedSuccess) {
			emit Approved(msg.sender, spender, amount);
		}

		return approvedSuccess;
	}
}
