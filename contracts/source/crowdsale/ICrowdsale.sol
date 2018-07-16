pragma solidity ^0.4.24;

/**
 * ICrowdsale
 *
 * Base crowdsale interface to manage the sale of 
 * an ERC20 token
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface ICrowdsale {

    /**
     * Returns true if the contract is currently in the presale phase
     *
     * @return True if in presale phase
     */
    function isInPresalePhase() external view returns (bool);


    /**
     * Returns true if the contract is currently in the ended stage
     *
     * @return True if ended
     */
    function isEnded() external view returns (bool);


    /**
     * Gets the amount of release dates for `_beneficiary` at which 
     * balances are released
     * 
     * @param _beneficiary The account that the balances are allocated for
     * @return Amount of release dates
     */
    function getReleaseDateCount(address _beneficiary) external view returns (uint);


    /**
     * Gets the release date for `_beneficiary` at `_index` at which a 
     * balance is released
     * 
     * @param _beneficiary The account that the balance is allocated for
     * @param _index Index of the release date
     * @return Release date
     */
    function getReleaseDateAtIndex(address _beneficiary, uint64 _index) external view returns (uint64);


     /**
     * Get the allocated token and ether balance of `_beneficiary` at `_releaseDate`
     *
     * @param _beneficiary The account that the balance is allocated for
     * @param _releaseDate The date after which the balance can be withdrawn
     * @return allocated ether balance, allocated token balance
     */
    function getAllocatedBalanceAtReleaseDate(address _beneficiary, uint64 _releaseDate) external view returns (uint, uint);


    /** 
     * Get the allocated token and ether balance of `_beneficiary` without taking release dates into account
     * 
     * @param _beneficiary The address from which the allocated balance will be retrieved
     * @return allocated ether balance, allocated token balance
     */
    function getAllocatedBalance(address _beneficiary) external view returns (uint, uint);


    /** 
     * Get the refundable ether balance of `_beneficiary`
     * 
     * @param _beneficiary The address from which the balance will be retrieved
     * @return refunable ether balance
     */
    function getRefundableBalance(address _beneficiary) external view returns (uint);


    /**
     * Returns the current phase based on the current time
     *
     * @return The index of the current phase
     */
    function getCurrentPhase() external view returns (uint);


    /**
     * Returns the rate
     *
     * @param _phase The phase to use while determining the rate
     * @param _volume The amount wei used to determine what volume multiplier to use
     * @return The rate used in `_phase` multiplied by the corresponding volume multiplier
     */
    function getRate(uint _phase, uint _volume) external view returns (uint);


    /**
     * Convert `_wei` to an amount in tokens using 
     * the `_rate`
     *
     * @param _wei amount of wei to convert
     * @param _rate rate to use for the conversion
     * @return Amount in tokens
     */
    function toTokens(uint _wei, uint _rate) external view returns (uint);


    /**
     * Receive ether and issue tokens to the sender
     * 
     * This function requires that msg.sender is not a contract. This is required because it's 
     * not possible for a contract to specify a gas amount when calling the (internal) send() 
     * function. Solidity imposes a maximum amount of gas (2300 gas at the time of writing)
     * 
     * Contracts can call the contribute() function instead
     */
    function () external payable;


    /**
     * Receive ether and issue tokens to the sender
     *
     * @return The accepted ether amount
     */
    function contribute() external payable returns (uint);


    /**
     * Receive ether and issue tokens to `_beneficiary`
     *
     * @param _beneficiary The account that receives the tokens
     * @return The accepted ether amount
     */
    function contributeFor(address _beneficiary) external payable returns (uint);


    /**
     * Withdraw allocated tokens
     */
    function withdrawTokens() external;


     /**
     * Withdraw allocated tokens
     *
     * @param _beneficiary Address to send to
     */
    function withdrawTokensTo(address _beneficiary) external;


    /**
     * Withdraw allocated ether
     */
    function withdrawEther() external;


    /**
     * Withdraw allocated ether
     *
     * @param _beneficiary Address to send to
     */
    function withdrawEtherTo(address _beneficiary) external;


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end of the crowdsale
     */
    function refund() external;


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end of the crowdsale
     *
     * @param _beneficiary Address to send to
     */
    function refundTo(address _beneficiary) external;
}