pragma solidity ^0.4.24;

import "./IObservable.sol";

/**
 * Abstract Observable
 *
 * Allows observers to register and unregister with the the 
 * implementing smart-contract that is observable
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract Observable is IObservable {

    // Observers
    mapping (address => uint) private observers;
    address[] private observerIndex;


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) external view returns (bool) {
        return _isObserver(_account);
    }


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function _isObserver(address _account) internal view returns (bool) {
        return observers[_account] < observerIndex.length && _account == observerIndex[observers[_account]];
    }


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() external view returns (uint) {
        return observerIndex.length;
    }


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) external view returns (address) {
        return observerIndex[_index];
    }


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer) external {
        require(canRegisterObserver(_observer));
        if (!_isObserver(_observer)) {
            observers[_observer] = observerIndex.push(_observer) - 1;
        }
    }


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer) external {
        require(canUnregisterObserver(_observer));
        if (_isObserver(_observer)) {
            uint indexToDelete = observers[_observer];
            address keyToMove = observerIndex[observerIndex.length - 1];
            observerIndex[indexToDelete] = keyToMove;
            observers[keyToMove] = indexToDelete;
            observerIndex.length--;
        }
    }


    /**
     * Returns whether it is allowed to register `_observer` by calling 
     * canRegisterObserver() in the implementing smart-contract
     *
     * @param _observer The address to register as an observer
     * @return Whether the sender is allowed or not
     */
    function canRegisterObserver(address _observer) internal view returns (bool);


    /**
     * Returns whether it is allowed to unregister `_observer` by calling 
     * canRegisterObserver() in the implementing smart-contract
     *
     * @param _observer The address to unregister as an observer
     * @return Whether the sender is allowed or not
     */
    function canUnregisterObserver(address _observer) internal view returns (bool);
}
