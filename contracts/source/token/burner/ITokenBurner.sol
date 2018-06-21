pragma solidity ^0.4.24;

/**
 * ITokenBurner
 *
 * Provides the ability to burn tokens 
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface ITokenBurner {
    
    /**
     * Returns true if '_token' is the token that is 
     * burned by this token burner
     * 
     * @param _token The address being tested
     * @return Whether the '_token' is part of this token burner
     */
    function isToken(address _token) external view returns (bool);


    /**
     * Returns the token that is burned by this 
     * token burner
     * 
     * @return The token that is part of this token burner
     */
    function getToken() external view returns (address);


    /**
     * Burn current balance
     */
    function burn() external;
}