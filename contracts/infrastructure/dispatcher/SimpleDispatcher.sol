pragma solidity ^0.4.24;

/**
 * The dispatcher is a minimal 'shim' that dispatches calls to a targeted
 * contract without returning any data
 *
 * Calls are made using 'delegatecall', meaning all storage and value
 * is kept on the dispatcher
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract SimpleDispatcher {

    /**
     * Target contract that contains the code
     */
    address private target;


    /**
     * Initialize simple dispatcher
     *
     * @param _target Contract that holds the code
     */
    constructor(address _target) public {
        target = _target;
    }


    /**
     * Execute target code in the context of the dispatcher
     */
    function () public payable {
        address dest = target;
        assembly {
            calldatacopy(0x0, 0x0, calldatasize)
            switch delegatecall(sub(gas, 10000), dest, 0x0, calldatasize, 0, 0)
            case 0 { revert(0, 0) } // Throw
        }
    }
}