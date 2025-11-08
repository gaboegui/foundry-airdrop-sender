// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {TSender} from "../src/TSender.sol";
import {MockERC20} from "./MockERC20.sol";

contract TSenderTest is Test {
    TSender public tSender;
    MockERC20 public token;

    address[] public recipients;
    uint256[] public amounts;
    uint256 public totalAmount;

    function setUp() public {
        tSender = new TSender();
        token = new MockERC20("Mock Token", "MTK", 18);

        // Mint tokens to the test contract, which will be the msg.sender in tests
        token.mint(address(this), 1_000_000 * 10**18);

        // Setup airdrop data
        recipients.push(vm.addr(1));
        recipients.push(vm.addr(2));
        recipients.push(vm.addr(3));

        amounts.push(100 * 10**18);
        amounts.push(200 * 10**18);
        amounts.push(300 * 10**18);

        totalAmount = 600 * 10**18;
    }

    function test_SuccessfulAirdrop() public {
        // Approve the sender contract to spend the tokens
        token.approve(address(tSender), totalAmount);

        // Perform the airdrop
        tSender.airdropERC20(address(token), recipients, amounts, totalAmount);

        // Check balances of recipients
        assertEq(token.balanceOf(recipients[0]), amounts[0]);
        assertEq(token.balanceOf(recipients[1]), amounts[1]);
        assertEq(token.balanceOf(recipients[2]), amounts[2]);

        // Check that the sender contract has no tokens left
        assertEq(token.balanceOf(address(tSender)), 0);
    }

    function test_FailLengthMismatch() public {
        amounts.pop();
        vm.expectRevert(bytes4(keccak256("TSender__LengthsDontMatch()")));
        tSender.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

    function test_FailZeroAddress() public {
        recipients[0] = address(0);
        token.approve(address(tSender), totalAmount);
        vm.expectRevert(bytes4(keccak256("TSender__ZeroAddress()")));
        tSender.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

    function test_FailTotalAmountMismatch() public {
        token.approve(address(tSender), totalAmount + 1);
        vm.expectRevert(bytes4(keccak256("TSender__TotalDoesntAddUp()")));
        tSender.airdropERC20(address(token), recipients, amounts, totalAmount + 1);
    }

    function test_FailInsufficientAllowance() public {
        token.approve(address(tSender), totalAmount - 1);
        // The low-level call will fail, and it will revert with TSender__TransferFailed()
        vm.expectRevert(bytes4(keccak256("TSender__TransferFailed()")));
        tSender.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

}
