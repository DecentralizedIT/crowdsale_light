pragma solidity ^0.4.24;

import "./token/IToken.sol";
import "./token/ManagedToken.sol";
import "./token/observer/ITokenObserver.sol";
import "./token/retriever/TokenRetriever.sol";
import "../infrastructure/behaviour/Observable.sol";

/**
 * My token (MYT)
 *
 * MYT is an ERC20 token as outlined within the whitepaper.
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract MyToken is ManagedToken, Observable, TokenRetriever {

    /**
     * Construct the managed token
     */
    constructor() public ManagedToken("My Token", "MYT", 8, true) {}


    /**
     * Returns whether sender is allowed to register `_observer`
     *
     * @param _observer The address to register as an observer
     * @return Whether the sender is allowed or not
     */
    function canRegisterObserver(address _observer) internal view returns (bool) {
        return _observer != address(this) && _isOwner(msg.sender);
    }


    /**
     * Returns whether sender is allowed to unregister `_observer`
     *
     * @param _observer The address to unregister as an observer
     * @return Whether the sender is allowed or not
     */
    function canUnregisterObserver(address _observer) internal view returns (bool) {
        return msg.sender == _observer || _isOwner(msg.sender);
    }


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function issue(address _to, uint _value) external returns (bool) {
        bool result = super._issue(_to, _value);
        if (_isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(msg.sender, _value);
        }

        return result;
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * - Notifies registered observers when the observer receives tokens
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) external returns (bool) {
        bool result = super._transfer(_to, _value);
        if (_isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(msg.sender, _value);
        }

        return result;
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * - Notifies registered observers when the observer receives tokens
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) external returns (bool) {
        bool result = super._transferFrom(_from, _to, _value);
        if (_isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(_from, _value);
        }

        return result;
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) external only_owner {
        super._retrieveTokens(_tokenContract);
    }
}
