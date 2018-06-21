pragma solidity ^0.4.24;

import "./crowdsale/Crowdsale.sol";
import "./token/retriever/TokenRetriever.sol";
import "./account/member/MemberAccount.sol";
import "./account/member/MemberAccountDispatcher.sol";
import "./account/member/MemberAccountShared.sol";
import "./account/member/IMemberAccountCollection.sol";
import "../infrastructure/state/IPausable.sol";
import "../infrastructure/authentication/IAuthenticator.sol";
import "../infrastructure/ownership/ITransferableOwnership.sol";
import "../thirdparty/wings/source/IWingsAdapter.sol";

/**
 * MyCrowdsale
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
contract MyCrowdsale is Crowdsale, TokenRetriever, IPausable, IMemberAccountCollection, IWingsAdapter {

    // State
    bool private paused;

    // Authentication
    IAuthenticator[] private authenticators;
    bool private requireAuthentication;

    // Member accounts
    address public memberAccountShared;
    address private memberAccountCode;

    mapping(address => uint) private memberAccounts;
    address[] private memberAccountsIndex;


    // Events
    event MemberAccountCreated(address account);


    /**
     * Returns whether the implementing contract is 
     * currently paused or not
     *
     * @return Whether the paused state is active
     */
    function isPaused() external view returns (bool) {
        return paused;
    }


    /**
     * Change the state to paused
     */
    function pause() external only_owner {
        paused = true;
    }


    /**
     * Change the state to resume, undo the effects 
     * of calling pause
     */
    function resume() external only_owner {
        paused = false;
    }


    /**
     * Add an authenticator
     *
     * @param _authenticator The address of the authenticator
     */
    function addAuthenticator(address _authenticator) external only_owner at_stage(Stages.Deploying) {
        authenticators.push(IAuthenticator(_authenticator));
    }


    /**
     * Returns true if authentication is enabled and false 
     * otherwise
     *
     * @return Whether the converter is currently authenticating or not
     */
    function isAuthenticating() external view returns (bool) {
        return requireAuthentication;
    }


    /**
     * Enable authentication
     */
    function enableAuthentication() external only_owner {
        requireAuthentication = true;
    }


    /**
     * Disable authentication
     */
    function disableAuthentication() external only_owner {
        requireAuthentication = false;
    }


    /**
     * Validate a contributing account
     *
     * @param _contributor Address that is being validated
     * @return Wheter the contributor is accepted or not
     */
    function isAcceptedContributor(address _contributor) internal view returns (bool) {
        if (!requireAuthentication) {
            return true;
        }

        for (uint i = 0; i < authenticators.length; i++) {
            if (!authenticators[i].authenticate(_contributor)) {
                return false;
            }
        }

        return true;
    }


    /**
     * Indicate if contributions are currently accepted
     *
     * @return Wheter contributions are accepted or not
     */
    function isAcceptingContributions() internal view returns (bool) {
        return !paused;
    }


    /**
     * Wings integration - Get the total raised amount of Ether
     *
     * Can only increased, means if you withdraw ETH from the wallet, should be not modified (you can use two fields 
     * to keep one with a total accumulated amount) amount of ETH in contract and totalCollected for total amount of ETH collected
     *
     * @return Total raised Ether amount
     */
    function totalCollected() external view returns (uint) {
        return raised;
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) external only_owner {
        ITokenRetriever(token).retrieveTokens(_tokenContract); // Retrieve tokens that belong to our token contract
        _retrieveTokens(_tokenContract); // Retrieve tokens that belong to our crowdsale
    }


    /**
     * Setup member account management
     *
     * @param _lockStake Min amount of wei required to obtain a lock
     * @param _lockDuration Time that a lock is valid
     */
    function setupMemberAccounts(uint _lockStake, uint _lockDuration) external only_owner at_stage(Stages.Deploying) {
        memberAccountShared = new MemberAccountShared(this, token, _lockStake, _lockDuration);
        memberAccountCode = new MemberAccount(memberAccountShared, 0x0);
        ITransferableOwnership(memberAccountShared).transferOwnership(msg.sender);
    }


    /**
     * Gets the amount of registered accounts
     * 
     * @return Amount of accounts
     */
    function getMemberAccountCount() public view returns (uint) {
        return memberAccountsIndex.length;
    }


    /**
     * Gets the accout at `_index`
     * 
     * @param _index The index of the account
     * @return Account location
     */
    function getMemberAccountAtIndex(uint _index) public view returns (address) {
        return memberAccountsIndex[_index];
    }


    /**
     * Create an account for a member
     *
     * @param _passphraseHash Hashed user passphrase
     * @return Member account
     */
    function createMemberAccount(bytes32 _passphraseHash) public only_owner returns (address) {
        address account = new MemberAccountDispatcher(memberAccountCode, memberAccountShared, _passphraseHash);
        memberAccounts[account] = memberAccountsIndex.push(account) - 1;

        emit MemberAccountCreated(account); // Notify
        return account;
    }
}