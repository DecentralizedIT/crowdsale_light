pragma solidity ^0.4.24;

/**
 * ITransferableOwnership
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface ITransferableOwnership {
    
    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) external;
}
