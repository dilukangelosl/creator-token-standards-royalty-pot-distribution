// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../access/OwnablePermissions.sol";
import "../interfaces/ICreatorToken.sol";
import "../interfaces/ITransferValidator.sol";
import "./TransferValidation.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";

/**
 * @title CreatorTokenBase
 * @author Limit Break, Inc.
 * @notice CreatorTokenBaseV3 is an abstract contract that provides basic functionality for managing token 
 * transfer policies through an implementation of ICreatorTokenTransferValidator/ICreatorTokenTransferValidatorV2/ICreatorTokenTransferValidatorV3. 
 * This contract is intended to be used as a base for creator-specific token contracts, enabling customizable transfer 
 * restrictions and security policies.
 *
 * <h4>Features:</h4>
 * <ul>Ownable: This contract can have an owner who can set and update the transfer validator.</ul>
 * <ul>TransferValidation: Implements the basic token transfer validation interface.</ul>
 *
 * <h4>Benefits:</h4>
 * <ul>Provides a flexible and modular way to implement custom token transfer restrictions and security policies.</ul>
 * <ul>Allows creators to enforce policies such as account and codehash blacklists, whitelists, and graylists.</ul>
 * <ul>Can be easily integrated into other token contracts as a base contract.</ul>
 *
 * <h4>Intended Usage:</h4>
 * <ul>Use as a base contract for creator token implementations that require advanced transfer restrictions and 
 *   security policies.</ul>
 * <ul>Set and update the ICreatorTokenTransferValidator implementation contract to enforce desired policies for the 
 *   creator token.</ul>
 *
 * <h4>Compatibility:</h4>
 * <ul>Backward and Forward Compatible - V1/V2/V3 Creator Token Base will work with V1/V2/V3 Transfer Validators.</ul>
 */
abstract contract CreatorTokenBase is OwnablePermissions, TransferValidation, ICreatorToken {

    error CreatorTokenBase__InvalidTransferValidatorContract();

    address public constant DEFAULT_TRANSFER_VALIDATOR = address(0x721C00182a990771244d7A71B9FA2ea789A3b433);

    bool private isValidatorInitialized;
    address private transferValidator;

    /**
     * @notice Sets the transfer validator for the token contract.
     *
     * @dev    Throws when provided validator contract is not the zero address and doesn't support 
     *         the ICreatorTokenTransferValidator or ICreatorTokenTransferValidatorV2 interface. 
     * @dev    Throws when the caller is not the contract owner.
     *
     * @dev    <h4>Postconditions:</h4>
     *         1. The transferValidator address is updated.
     *         2. The `TransferValidatorUpdated` event is emitted.
     *
     * @param transferValidator_ The address of the transfer validator contract.
     */
    function setTransferValidator(address transferValidator_) public {
        _requireCallerIsContractOwner();

        bool isValidTransferValidator = transferValidator_.code.length > 0;

        if(transferValidator_ != address(0) && !isValidTransferValidator) {
            revert CreatorTokenBase__InvalidTransferValidatorContract();
        }

        emit TransferValidatorUpdated(address(getTransferValidator()), transferValidator_);

        isValidatorInitialized = true;
        transferValidator = transferValidator_;
    }

    /**
     * @notice Returns the transfer validator contract address for this token contract.
     */
    function getTransferValidator() public view override returns (address validator) {
        validator = transferValidator;

        if (validator == address(0)) {
            if (!isValidatorInitialized) {
                validator = DEFAULT_TRANSFER_VALIDATOR;
            }
        }
    }

    /**
     * @dev Pre-validates a token transfer, reverting if the transfer is not allowed by this token's security policy.
     *      Inheriting contracts are responsible for overriding the _beforeTokenTransfer function, or its equivalent
     *      and calling _validateBeforeTransfer so that checks can be properly applied during token transfers.
     *
     * @dev Be aware that if the msg.sender is the transfer validator, the transfer is automatically permitted, as the
     *      transfer validator will have pre-validated the transfer.
     *
     * @dev Throws when the transfer doesn't comply with the collection's transfer policy, if the transferValidator is
     *      set to a non-zero address.
     *
     * @param caller  The address of the caller.
     * @param from    The address of the sender.
     * @param to      The address of the receiver.
     */
    function _preValidateTransfer(
        address caller, 
        address from, 
        address to, 
        uint256 tokenId, 
        uint256 /*value*/) internal virtual override {
        address validator = getTransferValidator();

        if (validator != address(0)) {
            if (msg.sender == validator) {
                return;
            }

            ITransferValidator(validator).validateTransfer(caller, from, to, tokenId);
        }
    }

    /**
     * @dev Pre-validates a token transfer, reverting if the transfer is not allowed by this token's security policy.
     *      Inheriting contracts are responsible for overriding the _beforeTokenTransfer function, or its equivalent
     *      and calling _validateBeforeTransfer so that checks can be properly applied during token transfers.
     *
     * @dev Be aware that if the msg.sender is the transfer validator, the transfer is automatically permitted, as the
     *      transfer validator will have pre-validated the transfer.
     *
     * @dev Throws when the transfer doesn't comply with the collection's transfer policy, if the transferValidator is
     *      set to a non-zero address.
     *
     * @param caller  The address of the caller.
     * @param from    The address of the sender.
     * @param to      The address of the receiver.
     */
    function _preValidateTransfer(
        address caller, 
        address from, 
        address to, 
        uint256 tokenId, 
        uint256 amount,
        uint256 /*value*/) internal virtual override {
        address validator = getTransferValidator();

        if (validator != address(0)) {
            if (msg.sender == validator) {
                return;
            }

            ITransferValidator(validator).validateTransfer(caller, from, to, tokenId, amount);
        }
    }
}
