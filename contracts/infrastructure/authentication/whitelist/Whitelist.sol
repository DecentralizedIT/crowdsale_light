pragma solidity ^0.4.24;

import "./IWhitelist.sol";
import "../IAuthenticator.sol";
import "../../ownership/TransferableOwnership.sol";

/**
 * Whitelist authentication list
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract Whitelist is IWhitelist, IAuthenticator, TransferableOwnership {

    struct Entry {
        bool accepted;
        uint128 datetime;
        uint128 index;
    }

    mapping(address => Entry) internal list;
    address[] internal listIndex;


    /**
     * Returns whether an entry exists for `_account`
     *
     * @param _account The account to check
     * @return whether `_account` is has an entry in the whitelist
     */
    function hasEntry(address _account) external view returns (bool) {
        return _hasEntry(_account);
    }


    /**
     * Returns whether an entry exists for `_account`
     *
     * @param _account The account to check
     * @return whether `_account` is has an entry in the whitelist
     */
    function _hasEntry(address _account) internal view returns (bool) {
        return listIndex.length > 0 && _account == listIndex[list[_account].index];
    }


    /**
     * Add `_account` to the whitelist
     *
     * If an account is currently disabled, the account is reenabled, otherwise 
     * a new entry is created
     *
     * @param _account The account to add
     */
    function add(address _account) external only_owner {
        if (!_hasEntry(_account)) {
            list[_account] = Entry(
                true, uint128(now), uint128(listIndex.push(_account) - 1));
        } else {
            Entry storage entry = list[_account];
            if (!entry.accepted) {
                entry.accepted = true;
                entry.datetime = uint128(now);
            }
        }
    }


    /**
     * Remove `_account` from the whitelist
     *
     * Will not acctually remove the entry but disable it by updating
     * the accepted record
     *
     * @param _account The account to remove
     */
    function remove(address _account) external only_owner {
        if (_hasEntry(_account)) {
            Entry storage entry = list[_account];
            entry.accepted = false;
            entry.datetime = uint128(now);
        }
    }


    /**
     * Authenticate 
     *
     * Returns whether `_account` is on the whitelist
     *
     * @param _account The account to authenticate
     * @return whether `_account` is successfully authenticated
     */
    function authenticate(address _account) external view returns (bool) {
        return list[_account].accepted;
    }
}