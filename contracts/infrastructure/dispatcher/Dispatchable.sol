pragma solidity ^0.4.24;

/**
 * Adds to the memory signature of the contract 
 * that contains the code that is called by the 
 * dispatcher
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract Dispatchable {

    /**
     * Target contract that contains the code
     */
    address private target;
}