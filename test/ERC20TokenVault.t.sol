// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../contracts/ERC20TokenVault.sol";
import "./MockERC20.sol";

contract ERC20TokenVaultTest {
    MockERC20 token;
    ERC20TokenVault vault;

    address user = address(0x1);
    address otherUser = address(0x2);

    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        token = new MockERC20();
        vault = new ERC20TokenVault(address(token));

        token.mint(user, INITIAL_BALANCE);
        token.mint(otherUser, INITIAL_BALANCE);
    }

    function testInitialState() public {
        require(
            vault.owner() == address(this),
            "Wrong owner"
        );

        require(
            vault.totalDeposited() == 0,
            "Initial deposits should be zero"
        );

        require(
            !vault.paused(),
            "Vault should not be paused"
        );
    }

    function testDeposit() public {
        uint256 amount = 100 ether;

        token.approve(address(vault), amount);

        vault.deposit(amount);

        require(
            vault.balanceOf(address(this)) == amount,
            "Incorrect vault balance"
        );

        require(
            vault.totalDeposited() == amount,
            "Incorrect total deposits"
        );
    }

    function testWithdraw() public {
        uint256 amount = 100 ether;

        token.approve(address(vault), amount);
        vault.deposit(amount);

        vault.withdraw(amount);

        require(
            vault.balanceOf(address(this)) == 0,
            "Vault balance should be zero"
        );

        require(
            vault.totalDeposited() == 0,
            "Total deposits should be zero"
        );
    }

    function testPartialWithdrawal() public {
        uint256 depositAmount = 200 ether;
        uint256 withdrawAmount = 75 ether;

        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);

        vault.withdraw(withdrawAmount);

        require(
            vault.balanceOf(address(this))
                == depositAmount - withdrawAmount,
            "Incorrect remaining balance"
        );

        require(
            vault.totalDeposited()
                == depositAmount - withdrawAmount,
            "Incorrect total deposits"
        );
    }

    function testPause() public {
        vault.pause();

        require(
            vault.paused(),
            "Vault should be paused"
        );
    }

    function testUnpause() public {
        vault.pause();
        vault.unpause();

        require(
            !vault.paused(),
            "Vault should be unpaused"
        );
    }

    function testOwnershipTransfer() public {
        vault.transferOwnership(user);

        require(
            vault.owner() == user,
            "Ownership transfer failed"
        );
    }
}
