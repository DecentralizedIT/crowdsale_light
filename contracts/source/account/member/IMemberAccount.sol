pragma solidity ^0.4.24;

/**
 * IMemberAccount 

 * #created 12/06/2018
 * #author Frank Bonnet
 */
interface IMemberAccount {

    /**
     * Invest received ether in target crowdsale
     */
    function invest() external;


    /**
     * Request a refund from the target crowdsale
     */
    function refund() external;


    /**
     * Request outstanding ether balance from the 
     * target crowdsale
     */
    function updateEtherBalance() external;


    /**
     * Request outstanding token balance from the 
     * target crowdsale
     */
    function updateTokenBalance() external;
}