// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @title IERC20
 * @dev Interface for the ERC20 standard.
 */
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title Sender contract to allow AirDrops
 * @author Gabriel Eguiguren P.
 * @notice all documentation on: https://github.com/gaboegui/foundry-airdrop-sender
 * @dev TSender.sol is fair more gas efficient in deployment specially
 */
contract Sender {
    error Sender__RecipientsAndAmountsLengthMismatch();
    error Sender__RecipientIsZeroAddress();
    error Sender__TransferFromFailed();
    error Sender__TransferFailed();
    error Sender__TotalAmountMismatch();

    /**
     * @notice Airdrops ERC20 tokens to multiple recipients.
     * @dev This function is optimized for gas by performing one `transferFrom`
     *      and then multiple `transfer` calls in a loop.
     * @param tokenAddress - the address of the ERC20 token to airdrop
     * @param recipients - the addresses to airdrop to
     * @param amounts - the amounts to airdrop to each address
     * @param totalAmount - the total amount to airdrop, must equal the sum of amounts.
     *
     * This function additionally has the following checks:
     * - Reverts if ETH is sent.
     * - Reverts if recipient is the zero address.
     * - Reverts on ERC20 transfer or transferFrom failure.
     * - Reverts if the sum of `amounts` does not equal `totalAmount`.
     */
    function airdropERC20(
        address tokenAddress,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 totalAmount
    ) external {
        uint256 numRecipients = recipients.length;
        if (numRecipients != amounts.length) {
            revert Sender__RecipientsAndAmountsLengthMismatch();
        }

        IERC20 token = IERC20(tokenAddress);

        // Move tokens from the caller to this contract.n        
        // The caller must have approved this contract to spend `totalAmount` of tokens.
        if (totalAmount > 0) {
            if (!token.transferFrom(msg.sender, address(this), totalAmount)) {
                revert Sender__TransferFromFailed();
            }
        }

        uint256 sumAmounts = 0;
        for (uint256 i = 0; i < numRecipients; ) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];

            if (recipient == address(0)) {
                revert Sender__RecipientIsZeroAddress();
            }

            // The check for transfer return value is important for security.
            if (!token.transfer(recipient, amount)) {
                revert Sender__TransferFailed();
            }
            sumAmounts += amount;
            unchecked {
                i++;
            }
        }

        if (sumAmounts != totalAmount) {
            revert Sender__TotalAmountMismatch();
        }
    }
}
