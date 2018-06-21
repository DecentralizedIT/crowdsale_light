pragma solidity ^0.4.24;

/**
 * ITokenObserver
 *
 * Allows a token smart-contract to notify observers 
 * when tokens are received
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface ITokenObserver {

    /**
     * Called by the observed token smart-contract in order 
     * to notify the token observer when tokens are received
     *
     * @param _from The address that the tokens where send from
     * @param _value The amount of tokens that was received
     */
    function notifyTokensReceived(address _from, uint _value) external;
}
