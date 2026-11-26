// Centralization vs Decentralization
// a single DB    vs Distributed Ledger DB
// a single BN    vs BN network (특정 노드 하나만으로 네트워크 변형 불가=신뢰도 유지)

// governance --> voting
// A agenda --> bt vote --> decision   (투표=탈중앙화)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract ManagedAccess {
    address public owner;
    address public manager;

    constructor(address _owner, address _manager) {
        owner = _owner;
        manager = _manager;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized");
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "You are not authorized to manage this contract"
        );
        _;
    }
}
