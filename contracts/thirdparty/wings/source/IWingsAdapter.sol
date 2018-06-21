pragma solidity ^0.4.24;

/**
 * IWingsAdapter
 * 
 * WINGS DAO Price Discovery & Promotion Pre-Beta https://www.wings.ai
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
interface IWingsAdapter {

    /**
     * Get the total raised amount of Ether
     *
     * Can only increase, meaning if you withdraw ETH from the wallet, it should be not modified (you can use two fields 
     * to keep one with a total accumulated amount) amount of ETH in contract and totalCollected for total amount of ETH collected
     *
     * @return Total raised Ether amount
     */
    function totalCollected() external view returns (uint);
}
