pragma solidity ^0.4.24;

import "../../../infrastructure/dispatcher/SimpleDispatcher.sol";

/**
 * MemberAccount Dispatcher
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
contract MemberAccountDispatcher is SimpleDispatcher {

    // FlyWeight - Shared data
    address public shared;

    /**
     * If set, calls are only accepted from 
     * the authorized account
     */
    address public authorizedAccount;

    /**
     * Hashed version of the password, updated 
     * after each successfull match
     */
    bytes32 internal passphraseHash;


    /**
     * Construct the account requiring a hashed passphrase
     *
     * @param _target Target contract that holds the code
     * @param _shared Flyweight - shared data
     * @param _passphraseHash Hashed user passphrase
     */
    constructor(address _target, address _shared, bytes32 _passphraseHash) public 
        SimpleDispatcher(_target) {
        shared = _shared;
        passphraseHash = _passphraseHash;
    }
}