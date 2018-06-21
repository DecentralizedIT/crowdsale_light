pragma solidity ^0.4.24;

import "./IMultiOwned.sol";

/**
 * MultiOwned
 *
 * Allows multiple owners
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract MultiOwned is IMultiOwned {

    // Owners
    mapping (address => uint) private owners;
    address[] private ownersIndex;


     /**
     * Access is restricted to owners only
     */
    modifier only_owner() {
        require(_isOwner(msg.sender));
        _;
    }


    /**
     * The publisher is the initial owner
     */
    constructor() public {
        ownersIndex.push(msg.sender);
        owners[msg.sender] = 0;
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) external view returns (bool) {
        return _isOwner(_account);
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function _isOwner(address _account) internal view returns (bool) {
        return owners[_account] < ownersIndex.length && _account == ownersIndex[owners[_account]];
    }


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() external view returns (uint) {
        return ownersIndex.length;
    }


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) external view returns (address) {
        return ownersIndex[_index];
    }


    /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account) external only_owner {
        if (!_isOwner(_account)) {
            owners[_account] = ownersIndex.push(_account) - 1;
        }
    }


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account) external only_owner {
        if (_isOwner(_account)) {
            uint indexToDelete = owners[_account];
            address keyToMove = ownersIndex[ownersIndex.length - 1];
            ownersIndex[indexToDelete] = keyToMove;
            owners[keyToMove] = indexToDelete; 
            ownersIndex.length--;
        }
    }
}
