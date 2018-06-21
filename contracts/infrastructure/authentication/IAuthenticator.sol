pragma solidity ^0.4.24;

/**
 * IAuthenticator 
 *
 * Authenticator interface
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface IAuthenticator {
    
    /**
     * Authenticate 
     *
     * Returns whether `_account` is authenticated or not
     *
     * @param _account The account to authenticate
     * @return whether `_account` is successfully authenticated
     */
    function authenticate(address _account) external view returns (bool);
}