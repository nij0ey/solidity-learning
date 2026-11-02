// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract MultiManagedAccess {
    address[] public managers;
    mapping(address => bool) public isManager;
    mapping(address => bool) public confirmed;

    constructor(address[] memory _managers) {
        for (uint256 i = 0; i < _managers.length; i++) {
            isManager[_managers[i]] = true;
            managers.push(_managers[i]);
        }
    }

    modifier onlyManager() {
        require(isManager[msg.sender], "You are not a manager");
        _;
    }

    modifier onlyAllConfirmed() {
        require(isManager[msg.sender], "You are not a manager");
        for (uint256 i = 0; i < managers.length; i++) {
            require(confirmed[managers[i]], "Not all confirmed yet");
        }
        _;
    }

    // manager confirm
    function confirm() external onlyManager {
        confirmed[msg.sender] = true;
    }
}
