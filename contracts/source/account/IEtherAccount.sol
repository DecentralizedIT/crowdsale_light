pragma solidity ^0.4.24;

/**
 * IEtherAccount
 * 
 * Account to store and withdraw ether
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
interface IEtherAccount {
    
    /**
     * Withdraws `_value` wei into sender
     *
     * @param _value Amount to withdraw in wei
     * @param _passphrase Raw passphrasse 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawEther(uint _value, bytes32 _passphrase, bytes32 _passphraseHash) external;


    /**
     * Withdraws `_value` wei into `_to` 
     *
     * @param _to Receiving address
     * @param _value Amount to withdraw in wei
     * @param _passphrase Raw passphrasse 
     * @param _passphraseHash Hash of the new passphrase 
     */
    function withdrawEtherTo(address _to, uint _value, bytes32 _passphrase, bytes32 _passphraseHash) external;
}
    