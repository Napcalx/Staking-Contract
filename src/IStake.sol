// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/solmate/src/tokens/ERC20.sol";

interface IStake {

    function mint(address _user, uint256 _amount) external;

    function burn(address _user, uint256 _amount) external;

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
