// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";
import "./ReentrancyGuard.sol";

contract ERC20TokenVault is ReentrancyGuard {
    IERC20 public immutable token;

    address public owner;

    bool public paused;

    uint256 public totalDeposited;

    mapping(address => uint256) private balances;

    event Deposited(
        address indexed user,
        uint256 amount
    );

    event Withdrawn(
        address indexed user,
        uint256 amount
    );

    event Paused(address indexed account);

    event Unpaused(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Vault is paused");
        _;
    }

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Invalid token");

        token = IERC20(tokenAddress);
        owner = msg.sender;
    }

    function deposit(uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "Amount must be greater than zero");

        bool success = token.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        require(success, "Transfer failed");

        balances[msg.sender] += amount;
        totalDeposited += amount;

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "Amount must be greater than zero");
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= amount;
        totalDeposited -= amount;

        bool success = token.transfer(
            msg.sender,
            amount
        );

        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    function balanceOf(address user)
        external
        view
        returns (uint256)
    {
        return balances[user];
    }

    function pause()
        external
        onlyOwner
    {
        require(!paused, "Already paused");

        paused = true;

        emit Paused(msg.sender);
    }

    function unpause()
        external
        onlyOwner
    {
        require(paused, "Not paused");

        paused = false;

        emit Unpaused(msg.sender);
    }

    function transferOwnership(address newOwner)
        external
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Invalid owner"
        );

        owner = newOwner;
    }
}
