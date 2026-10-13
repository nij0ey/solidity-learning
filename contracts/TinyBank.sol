// staking
// deposit(MyToken) / withdraw(MyToken)

// MyToken : token balance 관리
// -the balance of TinyBank address
// TinyBank : deposit(예금) / withdraw(출금) vault(금고, 핵심기능!)
// - users token 관리
// - user(예금 요청) --> deposit --> TinyBank --> MyToken의 transfer(user --> TinyBank)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    function transfer(uint256 amount, address to) external;

    function transferFrom(address from, address to, uint256 amount) external;
}

contract TinyBank {
    event Staked(address, uint256);

    IMyToken public stakingToken;
    mapping(address => uint256) public staked; //어느 유저가 얼만큼 staking 했는지
    uint256 public totalStaked; //유저들의 stake 총량

    constructor(IMyToken _stakingToken) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 _amount) external {
        require(_amount >= 0, "cannot stake 0 amount");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }
}
