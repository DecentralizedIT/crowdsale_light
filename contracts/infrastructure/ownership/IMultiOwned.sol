pragma solidity ^0.4.24;

/**
 * IMultiOwned
 *
 * Interface that allows multiple owners
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface IMultiOwned {

    /**
     * Returns true if `_account` is an owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) external view returns (bool);


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() external view returns (uint);


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) external view returns (address);


     /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account) external;


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account) external;
}
