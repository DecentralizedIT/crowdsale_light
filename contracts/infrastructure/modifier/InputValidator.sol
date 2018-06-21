pragma solidity ^0.4.24;

/**
 * Input validation
 *
 * Validates argument length
 *
 * #created 21/06/2018
 * #author Frank Bonnet
 */
contract InputValidator {

    /**
     * ERC20 Short Address Attack fix
     */
    modifier safe_arguments(uint _numArgs) {
        assert(msg.data.length >= _numArgs * 32 + 4);
        _;
    }
}