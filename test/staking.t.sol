// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Test, console2} from "lib/forge-std/src/Test.sol";
import { Staking } from "../src/Staking.sol";
import "../src/Receipt.sol";
import "../src/Napcalx.sol";

contract StakingTest is Test {
    Staking staking;
    Receipt receipt;
    Napcalx napcalx;

    event Staked(
        address indexed user,
        uint256 amount
    );
    event Withdrawn(
        address indexed user, 
        uint256 amount
    );
    event RewardPaid(
        address indexed user,
        uint256 reward
    );
    event Compounded(
        address indexed user,
        uint256 amount, 
        uint256 newPrincipal
    );

    uint256 stakerPriv1;
    uint256 stakerPriv2;

    address staker1;
    address staker2;

    function setUp() public {
        staking = new Staking(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, napcalx, receipt);
        receipt = new Receipt();
        napcalx = new Napcalx()

        (staker1, stakerPriv1) = makeAddr("STAKER");
    }

    function makeAddr (string memory name) public returns (address addr, uint256 privKey) {
        privKey = uint256(keccak256(abi.encodePacked(name)));
        addr = vm.addr(privKey);
        vm.label(addr, name);
    }

    function testMinStakeAmount() public {
        staking.stakingAmount = 0;
        staking.stake(0);
        vm.expectRevert(Staking.MinStakeAmount.selector);
    }


}
