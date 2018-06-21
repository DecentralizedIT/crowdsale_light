pragma solidity ^0.4.24;

/**
 * IObservable
 *
 * Allows observers to register and unregister with the 
 * implementing smart-contract that is observable
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface IObservable {

    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) external view returns (bool);


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() external view returns (uint);


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) external view returns (address);


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer) external;


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer) external;
}
