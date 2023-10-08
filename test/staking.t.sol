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
        receipt = Receipt();
        staking = new Staking(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), IStake(napcalx), IStake(receipt));
    }

    function testMinStakeAmount() public {
        stake();
        stake(stakingAmount) = 0;
        vm.expectRevert(Staking.MinStakeAmount.selector);
    }

    function testMaxStakeAmount() public {
        stake();
        stake.stakingAmount = 20;
        vm.expectRevert(staking.MaxStakeAmount.selector);
    }

    function testBalanceOverLimit() public {
        stake();
        stake.stakingAmount = 5;
        stake.balance = 501; 
        vm.expectRevert(Staking.BalanceOverLimit.selector);
    }

    function testNothingToWithdraw() public {
        stake();
        stake.stakingAmount = 3;
        stake.balance = 200;
        stake.stakedAmount = 0.009;
        vm.expectRevert(Staking.NothingToWithdraw.selector);
    }

    function testNoStakeToCompound() public {
        stake();
        stake.stakingAmount = 3;
        stake.balance = 200;
        stake.stakedAmount = 3;
        stake.stakedBalance = 0.08;
        vm.expectRevert(Staking.NoStakeToCompound.selector);
    }

    function testNoRewardToCompound() public {
        stake();
        stake.stakingAmount = 3;
        stake.balance = 200;
        stake.stakedAmount = 3;
        stake.stakedBakance = 0.1;
        stake.rewardAmount = 0.009;
        vm.expectRevert(Staking.NoRewardToCompound.selector);
    }

    function stake() internal payable returns (bool success) {
        uint256 stakingAmount = msg.value;
        success = stake(stakingAmount);
    }
}
