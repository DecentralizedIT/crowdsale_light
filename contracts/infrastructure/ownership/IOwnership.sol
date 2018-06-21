pragma solidity ^0.4.24;

/**
 * IOwnership
 *
 * Perminent ownership
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface IOwnership {

    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) external view returns (bool);


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() external view returns (address);
}
