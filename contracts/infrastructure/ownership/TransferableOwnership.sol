pragma solidity ^0.4.24;

import "./ITransferableOwnership.sol";
import "./Ownership.sol";

/**
 * TransferableOwnership
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract TransferableOwnership is ITransferableOwnership, Ownership {

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) external only_owner {
        owner = _newOwner;
    }
}
