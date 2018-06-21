pragma solidity ^0.4.24;

/**
 * ITokenRetriever
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) external;
}