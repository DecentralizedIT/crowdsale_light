pragma solidity ^0.4.24;

import "./IMemberAccount.sol";
import "./IMemberAccountShared.sol";
import "../IAccount.sol";
import "../IEtherAccount.sol";
import "../ITokenAccount.sol";
import "../../token/IToken.sol";
import "../../token/retriever/TokenRetriever.sol";
import "../../crowdsale/ICrowdsale.sol";
import "../../../infrastructure/dispatcher/Dispatchable.sol";

/**
 * MemberAccount
 * 
 * Password protected account with optional caller 
 * enforcement protection
 *
 * - Store ether
 * - Store ERC20 tokens 
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
contract MemberAccount is Dispatchable, TokenRetriever, IAccount, IEtherAccount, ITokenAccount, IMemberAccount {

    // FlyWeight - Shared data
    IMemberAccountShared public shared;

    /**
     * If set, calls are only accepted from 
     * the authorized account
     */
    address public authorizedAccount;

    /**
     * Hashed version of the password, updated 
     * after each successful match
     */
    bytes32 internal passphraseHash;


    /**
     * Authentication
     * 
     * Basic (required)
     * Compares the provided password to the stored hash of the password. The 
     * passphrase is updated after each successful authentication to prevent 
     * a replay attack. 
     *
     * 2FA (optional)
     * Require the user to call from the stored authorized account 
     */
    modifier authenticate(bytes32 _passphrase, bytes32 _passphraseHash) {
        if (authorizedAccount != 0x0) {
            // Authorized
            require(authorizedAccount == msg.sender); // Require 2fa
        } 
        
        else {
            // Anonymous
            (address owner, uint until, uint stake) = shared.getLock(this);
            require(until >= now); // Is locked?
            require(owner == msg.sender); // Owns lock?

            // Reset lock
            shared.removeLock();

            // Return stake
            if (stake > 0) {
                msg.sender.transfer(stake);
            }
        }

        // Require passphrase 
        require(_passphraseHash != 0x0);
        require(keccak256(abi.encodePacked(_passphrase)) == passphraseHash);
        passphraseHash = _passphraseHash; 

        _;
    }


    /**
     * Construct the account requiring a hashed passphrase
     *
     * @param _shared Flyweight - shared data
     * @param _passphraseHash Hashed user passphrase
     */
    constructor(address _shared, bytes32 _passphraseHash) public {
        shared = IMemberAccountShared(_shared);
        passphraseHash = _passphraseHash;
    }


    /**
     * Replace the hashed passphrase
     *
     * @param _passphrase Raw passphrase 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function resetPassphrase(bytes32 _passphrase, bytes32 _passphraseHash) public authenticate(_passphrase, _passphraseHash) {
        // Passphrase hash reset in modifier
    }


    /**
     * Calls will only be accepted from `_authorizedAccount` only
     *
     * @param _passphrase Raw passphrase 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function enable2fa(bytes32 _passphrase, bytes32 _passphraseHash) public authenticate(_passphrase, _passphraseHash) {
        authorizedAccount = msg.sender;
    }


    /**
     * Calls will only be accepted from anyone
     *
     * @param _passphrase Raw passphrase 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function disable2fa(bytes32 _passphrase, bytes32 _passphraseHash) public authenticate(_passphrase, _passphraseHash) {
        authorizedAccount = 0x0;
    }


    /**
     * Accept payments
     */
    function () public payable {
         // Just receive ether
    }


    /**
     * Invest received ether in target crowdsale
     */
    function invest() public {
        ICrowdsale(shared.getTargetCrowdsale()).contribute.value(address(this).balance)();
    }


    /**
     * Request a refund from the target crowdsale
     */
    function refund() public {
        ICrowdsale(shared.getTargetCrowdsale()).refund();
    }


    /**
     * Request outstanding ether balance from the 
     * target crowdsale
     */
    function updateEtherBalance() public {
        ICrowdsale(shared.getTargetCrowdsale()).withdrawEther();
    }


    /**
     * Withdraws `_value` wei into sender
     *
     * @param _value Amount to widthdraw in wei
     * @param _passphrase Raw passphrasse 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawEther(uint _value, bytes32 _passphrase, bytes32 _passphraseHash) public {
        withdrawEtherTo(msg.sender, _value, _passphrase, _passphraseHash);
    }


    /**
     * Withdraws `_value` wei into `_to` 
     *
     * @param _to Receiving address
     * @param _value Amount to widthdraw in wei
     * @param _passphrase Raw passphrasse 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawEtherTo(address _to, uint _value, bytes32 _passphrase, bytes32 _passphraseHash) public authenticate(_passphrase, _passphraseHash) {
        _to.transfer(_value);
    }


   /**
     * Request outstanding token balance from the 
     * target crowdsale
     */
    function updateTokenBalance() public {
        ICrowdsale(shared.getTargetCrowdsale()).withdrawTokens();
    }


    /**
     * Withdraws `_value` of `_token` into sender
     *
     * @param _value Amount to withdraw in tokens
     * @param _passphrase Raw passphrasse 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawTokens(uint _value, bytes32 _passphrase, bytes32 _passphraseHash) public {
        withdrawTokensTo(msg.sender, _value, _passphrase, _passphraseHash);
    }


    /**
     * Withdraws `_value` of `_token` into `_to` 
     *
     * @param _to Receiving address
     * @param _value Amount to withdraw in tokens
     * @param _passphrase Raw passphrasse 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawTokensTo(address _to, uint _value, bytes32 _passphrase, bytes32 _passphraseHash) public authenticate(_passphrase, _passphraseHash) {
        IToken targetToken = IToken(shared.getTargetToken());
        if (!IToken(targetToken).transfer(_to, _value)) {
            revert();
        }
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract, bytes32 _passphrase, bytes32 _passphraseHash) public authenticate(_passphrase, _passphraseHash) {
        require(shared.getTargetToken() != _tokenContract);
        super._retrieveTokens(_tokenContract);
    }
}