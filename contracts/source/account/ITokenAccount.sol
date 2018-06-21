pragma solidity ^0.4.24;

/**
 * ITokenAccount
 * 
 * Account capable of withdrawing ERC20 tokens
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
interface ITokenAccount {
    
    /**
     * Withdraws `_value` of `_token` into sender
     *
     * @param _value Amount to withdraw in tokens
     * @param _passphrase Raw passphrase 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawTokens(uint _value, bytes32 _passphrase, bytes32 _passphraseHash) external;


    /**
     *  Withdraws `_value` of `_token` into `_to` 
     *
     * @param _to Receiving address
     * @param _value Amount to withdraw in tokens
     * @param _passphrase Raw passphrase 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawTokensTo(address _to, uint _value, bytes32 _passphrase, bytes32 _passphraseHash) external;
}
    