// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Sender} from "../src/Sender.sol";
import {MockERC20} from "./MockERC20.sol";

contract SenderTest is Test {
    Sender public sender;
    MockERC20 public token;

    address[] public recipients;
    uint256[] public amounts;
    uint256 public totalAmount;

    function setUp() public {
        sender = new Sender();
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
        token.approve(address(sender), totalAmount);

        // Perform the airdrop
        sender.airdropERC20(address(token), recipients, amounts, totalAmount);

        // Check balances of recipients
        assertEq(token.balanceOf(recipients[0]), amounts[0]);
        assertEq(token.balanceOf(recipients[1]), amounts[1]);
        assertEq(token.balanceOf(recipients[2]), amounts[2]);

        // Check that the sender contract has no tokens left
        assertEq(token.balanceOf(address(sender)), 0);
    }

    function test_FailLengthMismatch() public {
        amounts.pop();
        vm.expectRevert(Sender.Sender__RecipientsAndAmountsLengthMismatch.selector);
        sender.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

    function test_FailZeroAddress() public {
        recipients[0] = address(0);
        token.approve(address(sender), totalAmount);
        vm.expectRevert(Sender.Sender__RecipientIsZeroAddress.selector);
        sender.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

    function test_FailTotalAmountMismatch() public {
        token.approve(address(sender), totalAmount + 1);
        vm.expectRevert(Sender.Sender__TotalAmountMismatch.selector);
        sender.airdropERC20(address(token), recipients, amounts, totalAmount + 1);
    }

    function test_FailInsufficientAllowance() public {
        token.approve(address(sender), totalAmount - 1);
        // The revert comes from the MockERC20 contract when transferFrom is called
        vm.expectRevert("ERC20: insufficient allowance");
        sender.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

}
