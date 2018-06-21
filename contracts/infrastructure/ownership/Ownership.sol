pragma solidity ^0.4.24;

import "./IOwnership.sol";

/**
 * Ownership
 *
 * Perminent ownership
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract Ownership is IOwnership {

    // Owner
    address internal owner;


    /**
     * Access is restricted to the current owner
     */
    modifier only_owner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * The publisher is the inital owner
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) external view returns (bool) {
        return _account == owner;
    }


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}
