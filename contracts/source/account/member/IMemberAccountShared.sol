pragma solidity ^0.4.24;

/**
 * IMemberAccountShared 
 *
 * FlyWeight
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
interface IMemberAccountShared {

     /**
     * Returns the address of the crowdsale contract that 
     * is being targeted
     *
     * @return Crowdsale address
     */
    function getTargetCrowdsale() external view returns (address);


    /**
     * Returns the address of the ERC20 Token contract that 
     * is being targeted
     *
     * @return Token address
     */
    function getTargetToken() external view returns (address);


    /**
     * Returns true if `_account` is locked currently. A locked account 
     * restricts authentication to the lock owner and can be overwritten 
     * by a valid node or enabled 2fa option
     *
     * @param _account Account that is locked or not
     * @return Wether the account is locked or not
     */
    function isLocked(address _account) external view returns (bool);


    /**
     * Returns the lock data for `_account`. The lock data includes the 
     * lock owner, the expiry time and the received stake
     *
     * @param _account Account for which to retreive the lock data
     * @return Lock owner, expiry time, received stake
     */
    function getLock(address _account) external view returns (address, uint, uint);


    /**
     * Obtain a lock on `_account`. Locking the account restricts authentication 
     * to the msg.sender and can be overwritten by a valid node or enabled 2fa option
     *
     * @param _account Account that will be locked
     */
    function lock(address _account) external payable;


    /**
     * Obtain a lock on `_account` for `_owner`. Locking the account restricts authentication 
     * to the `_owner` and can be overwritten by a valid node or enabled 2fa option
     *
     * @param _account Account that will be locked
     * @param _owner The owner of the lock
     */
    function lockFor(address _account, address _owner) external payable;


    /**
     * Remove a lock from `msg.account`. Locking the account restricts authentication 
     * to the msg.sender 
     */
    function removeLock() external;


    /**
     * Returns true if `_node` is a valid node
     *
     * @param _node The address to be checked
     * @return Wether _node is a valid node
     */
    function isNode(address _node) external view returns (bool);
}