// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/solmate/src/utils/FixedPointMathLib.sol";
import "./IStake.sol";

contract Staking {
    using FixedPointMathLib for uint256;

    IERC20 public wethToken; // Wrapped Ether (WETH) contract address
    IStake public _napcalx;
    IStake public _receipt;
    uint256 public constant APR = 14; // Annual Percentage Rate (14%)
    uint256 public constant COMPOUNDING_RATIO = 10; // 1:10 compounding ratio
    uint256 public constant COMPOUNDING_FEE = 1; // 1% fee for compounding per month
    uint256 public constant MAX_BALANCE = 500 ether; // Max Stake Amount of 5 Ether

    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastCompoundTimestamp;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Compounded(address indexed user, uint256 amount, uint256 newPrincipal);

    error MinStakeAmount();
    error MaxStakeAmount();
    error BalanceOverLimit();
    error NothingToWithdraw();
    error NoStakeToCompound();
    error NoRewardToCompound();

    constructor(
        address _wethTokenAddress,
        IStake Napcalx,
        IStake Receipt
    ) {
        wethToken = IERC20(_wethTokenAddress);
        Napcalx = _napcalx;
        Receipt = _receipt;
    }

    // Stake ETH and receive receipt tokens
    function stake() external payable returns(bool success){
        uint256 stakingAmount = msg.value;
        if(stakingAmount < 0.1 ether) revert MinStakeAmount();
        if(stakingAmount > 10 ether) revert MaxStakeAmount();
        if(address(this).balance >= MAX_BALANCE) revert BalanceOverLimit();
        
        // Mint receipt tokens to the depositor
        uint256 ReceiptToMint = stakingAmount; // 1 ETH = 1 receipt token (simplified)
        _receipt.mint(msg.sender, ReceiptToMint);

        // Update staked balances and rewards
        stakedBalances[msg.sender] = stakedBalances[msg.sender] + stakingAmount;
        success = true; 
        emit Staked(msg.sender, stakingAmount);
    }

    // Withdraw staked ETH and earned rewards
    function withdraw() external {
        uint256 stakedAmount = stakedBalances[msg.sender];
        if(stakedAmount < 0.1 ether) revert NothingToWithdraw();
        
        // Calculate and transfer rewards
        uint256 rewardAmount = calculateReward(msg.sender);
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(stakedAmount + (rewardAmount));
        emit Withdrawn(msg.sender, stakedAmount);

        // Convert WETH to ETH and send it back to the user
        wethToken.transfer(msg.sender, stakedAmount);
        lastCompoundTimestamp[msg.sender] = block.timestamp; // Reset compounding timestamp
    }

    // Calculate earned rewards
    function calculateReward(address user) internal view returns (uint256) {
        uint256 stakedAmount = stakedBalances[user];
        uint256 lastTimestamp = lastCompoundTimestamp[user];

        if (stakedAmount == 0 || lastTimestamp == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - (lastTimestamp);
        uint256 reward = stakedAmount * (APR) * (timeElapsed) / (365 days) / (100);
        return reward;
    }

    // Allow users to opt in for compounding
    function compound() external {
        uint256 stakedBalance = stakedBalances[msg.sender];
        uint256 rewardAmount = calculateReward(msg.sender);

        if(stakedBalance < 0.1 ether) revert NoStakeToCompound();
        if(rewardAmount < 0.001 ether) revert NoRewardToCompound();

        uint256 compoundedAmount = rewardAmount * (COMPOUNDING_RATIO);
        uint256 fee = rewardAmount * (COMPOUNDING_FEE) /(100);

        // Burn reward tokens for the fee
        _napcalx.transferFrom(msg.sender, address(this), fee);
        _napcalx.burn(address(this), fee);

        // Convert the rest to WETH and stake as principal
        wethToken.transferFrom(msg.sender, address(this), compoundedAmount);
        stakedBalances[msg.sender] = stakedBalances[msg.sender] + (compoundedAmount);
        lastCompoundTimestamp[msg.sender] = block.timestamp;

        emit Compounded(msg.sender, compoundedAmount, stakedBalances[msg.sender]);
    }

    // Function to retrieve the contract's ETH balance
    function getEthBalance() external view returns (uint256 bal) {
        return bal = address(this).balance;
    }
}