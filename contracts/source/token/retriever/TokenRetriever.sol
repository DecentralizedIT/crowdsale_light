pragma solidity ^0.4.24;

import "./ITokenRetriever.sol";
import "../IToken.sol";

/**
 * TokenRetriever
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract TokenRetriever is ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) external {
        _retrieveTokens(_tokenContract);
    }


    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function _retrieveTokens(address _tokenContract) internal {
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(this);
        if (tokenBalance > 0) {
            tokenInstance.transfer(msg.sender, tokenBalance);
        }
    }
}