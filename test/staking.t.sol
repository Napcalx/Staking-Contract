// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Test, console2} from "lib/forge-std/src/Test.sol";
import { Staking } from "../src/Staking.sol";
import "../src/Receipt.sol";
import "../src/Napcalx.sol";
import "../src/IStake.sol";

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


    function setUp() public {
        napcalx = new Napcalx();
        receipt = new Receipt();
        staking = new Staking(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), IStake(napcalx), IStake(receipt));
    }

    function testMinStakeAmount() public {
        staking.stake(0);
        staking.stakingAmount = 0;
        vm.expectRevert(Staking.MinStakeAmount.selector);
    }

    function testMaxStakeAmount() public {
        staking.stake(0);
        staking.stakingAmount = 20;
        vm.expectRevert(staking.MaxStakeAmount.selector);
    }

    function testBalanceOverLimit() public {
        staking.stake(0);
        staking.stakingAmount = 5;
        staking.balance = 501; 
        vm.expectRevert(Staking.BalanceOverLimit.selector);
    }

    function testNothingToWithdraw() public {
        staking.stake(0);
        staking.stakingAmount = 3;
        staking.balance = 200;
        staking.stakedAmount = 0.009;
        vm.expectRevert(Staking.NothingToWithdraw.selector);
    }

    function testNoStakeToCompound() public {
        staking.stake(0);
        staking.stakingAmount = 3;
        staking.balance = 200;
        staking.stakedAmount = 3;
        staking.stakedBalance = 0.08;
        vm.expectRevert(Staking.NoStakeToCompound.selector);
    }

    function testNoRewardToCompound() public {
        staking.stake(0);
        staking.stakingAmount = 3;
        staking.balance = 200;
        staking.stakedAmount = 3;
        staking.stakedBakance = 0.1;
        staking.rewardAmount = 0.009;
        vm.expectRevert(Staking.NoRewardToCompound.selector);
    }
}
