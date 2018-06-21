pragma solidity ^0.4.24;

import "./Token.sol";
import "./IManagedToken.sol";
import "../../infrastructure/ownership/MultiOwned.sol";

/**
 * ManagedToken
 *
 * Adds the following functionality to the basic ERC20 token
 * - Locking
 * - Issuing
 * - Burning 
 *
 * #created 21/06/2018
 * #author Frank Bonnet
 */
contract ManagedToken is IManagedToken, Token, MultiOwned {

    // Token state
    bool internal locked;


    /**
     * Allow access only when not locked
     */
    modifier only_when_unlocked() {
        require(!locked);
        _;
    }


    /** 
     * Construct managed ERC20 token
     * 
     * @param _name The full token name
     * @param _symbol The token symbol (aberration)
     * @param _decimals The token precision
     * @param _locked Whether the token should be locked initially
     */
    constructor(string _name, string _symbol, uint8 _decimals, bool _locked) public 
        Token(_name, _symbol, _decimals) {
        locked = _locked;
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) external returns (bool) {
        return _transfer(_to, _value);
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function _transfer(address _to, uint _value) internal only_when_unlocked returns (bool) {
        return super._transfer(_to, _value);
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) external returns (bool) {
        return _transferFrom(_from, _to, _value);
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function _transferFrom(address _from, address _to, uint _value) internal only_when_unlocked returns (bool) {
        return super._transferFrom(_from, _to, _value);
    }


    /** 
     * Returns true if the token is locked
     * 
     * @return Whether the token is locked
     */
    function isLocked() external view returns (bool) {
        return locked;
    }


    /**
     * Locks the token so that the transfering of value is enabled 
     *
     * @return Whether the locking was successful or not
     */
    function lock() external only_owner returns (bool)  {
        locked = true;
        return locked;
    }


    /**
     * Unlocks the token so that the transfering of value is enabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() external only_owner returns (bool)  {
        locked = false;
        return !locked;
    }


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function issue(address _to, uint _value) external returns (bool) {
        _issue(_to, _value);
    }


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function _issue(address _to, uint _value) internal only_owner safe_arguments(2) returns (bool) {
        // Check for overflows
        require(balances[_to] + _value >= balances[_to]);

        // Create tokens
        balances[_to] += _value;
        totalTokenSupply += _value;

        // Notify listeners 
        emit Transfer(0, _to, _value);
        return true;
    }


    /**
     * Burns `_value` tokens of `_recipient`
     *
     * @param _from The address that owns the tokens to be burned
     * @param _value The amount of tokens to be burned
     * @return Whether the tokens where sucessfully burned or not
     */
    function burn(address _from, uint _value) external only_owner safe_arguments(2) returns (bool) {
        // Check if the token owner has enough tokens
        require(balances[_from] >= _value);

        // Burn tokens
        balances[_from] -= _value;
        totalTokenSupply -= _value;

        // Notify listeners 
        emit Transfer(_from, 0, _value);
        return true;
    }
}
