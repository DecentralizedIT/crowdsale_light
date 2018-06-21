pragma solidity ^0.4.24;

/**
 * IMemberAccountCollection 
 * 
 * Allows access to a collection of member accounts
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
interface IMemberAccountCollection {

    /**
     * Gets the amount of registered accounts
     * 
     * @return Amount of accounts
     */
    function getMemberAccountCount() external view returns (uint);


    /**
     * Gets the accout at `_index`
     * 
     * @param _index The index of the account
     * @return Account location
     */
    function getMemberAccountAtIndex(uint _index) external view returns (address);
}