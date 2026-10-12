// Token : smart contract based
// BTC, ETH, XRP, KAIA : native token (자기 토큰만 수수료로 받음)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyToken {
    event Transfer(address indexed from, address indexed to, uint256 value); // topics값에 들어갈 Hash 생성, unique한 값, index는 3개까지 지원
    event Approval(address indexed spender, uint256 amount);

    string public name;
    string public symbol;
    uint8 public decimals; // 1 ETH --> 1*10^18 wei, 1 wei --> 1*10^-18, uint8 --> 8bit unsigned int(~uint256=32byte)

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowance; // 의미: 두번째 address가 uint256만큼 허용해도 되는지에 대한 매핑을 가진 첫번째 address

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal,
        uint256 _amount
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimal;
        // transaction
        // from(보내는 이), to, data, value, gas..
        _mint(_amount * 10 ** uint256(decimals), msg.sender); // 1 MT 발행, decimal 변경할 때 적용 용이
    }

    function approve(address spender, uint256 amount) external {
        allowance[msg.sender][spender] = amount;
        emit Approval(spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external {
        address spender = msg.sender; // 중요!!
        require(allowance[from][spender] >= amount, "insufficient allowance");
        allowance[from][spender] -= amount;
        balanceOf[from] -= amount; // 취약한 부분
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(uint256 amount, address owner) internal {
        totalSupply += amount;
        balanceOf[owner] += amount;

        emit Transfer(address(0), owner, amount); //zero-address: 무에서 발행하여 거래함
    }

    function transfer(uint256 amount, address to) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }
}

/*
approve
 - allow spender address to send my token  (보안 취약, spender 주소의 신뢰도 높아야 함)
transferFrom
 - spender: owner -> target address

* token owner --> bank contract
* token owner -->  router contract --> bank contract
* token owner -->  router contract --> bank contract(multi contract)

*/
