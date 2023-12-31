// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/solmate/src/tokens/ERC20.sol";

contract Napcalx is ERC20 {
    constructor() ERC20("Napcalx", "NCX", 18) {}

    function mint(uint _amount) external {
        _mint(msg.sender, _amount);
    }
}