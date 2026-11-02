/*
staking
deposit(MyToken) / withdraw(MyToken)

MyToken : token balance 관리
- the balance of TinyBank address
TinyBank : deposit(예금) / withdraw(출금) vault(금고, 핵심기능!)
- users token 관리
- user(예금 요청) --> deposit --> TinyBank --> MyToken의 transfer(user --> TinyBank)
*/

/*
Reward
- reward token: MyToken
- reward resources: 1 MT/block minting
- reward strategy: staked[user]/totalStaked distribution

- signer0 block 0 staking
- signer1 block 5 staking
- 0-- 1-- 2-- 3-- 4-- 5--
  |                   |
- signer0 10MT        signer1 10MT
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    function transfer(uint256 amount, address to) external;

    function transferFrom(address from, address to, uint256 amount) external;

    function mint(uint256 amount, address owner) external;
}

contract TinyBank {
    event Staked(address from, uint256 amount);
    event Withdraw(uint256 amount, address to);

    IMyToken public stakingToken;

    mapping(address => uint256) public lastClaimedBlock; //올바른 분배를 위해 토큰 쌓기 시작한 블록에서부터 시작하게 해줌
    uint256 rewardPerBlock = 1 * 10 ** 18;

    mapping(address => uint256) public staked; //어느 유저가 얼만큼 staking 했는지
    uint256 public totalStaked; //유저들의 stake 총량

    constructor(IMyToken _stakingToken) {
        stakingToken = _stakingToken;
    }

    // 누가, 언제 호출?
    // 최초와 마지막일때 totalstaked가 0이 됨
    modifier updateReward(address to) {
        if (staked[to] > 0) {
            uint256 blocks = block.number - lastClaimedBlock[to];
            uint256 reward = (blocks * rewardPerBlock * staked[to]) /
                totalStaked;
            stakingToken.mint(reward, to);
        }
        lastClaimedBlock[to] = block.number;
        _; // motifier의 callers's code
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount >= 0, "cannot stake 0 amount");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(staked[msg.sender] >= _amount, "insufficient staked token");
        stakingToken.transfer(_amount, msg.sender); //순서 중요!, msg.sender = tinybank
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
        emit Withdraw(_amount, msg.sender);
    }
}
