// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/solmate/src/tokens/ERC20.sol";

contract Receipt is ERC20 ("Receipt", "RCT", 18) {

    function mint(uint _amount) external {
        _mint(msg.sender, _amount);
    }
}