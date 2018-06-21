pragma solidity ^0.4.24;

/**
 * IPausable
 *
 * Simple interface to pause and resume 
 *
 * #created 11/10/2017
 * #author Frank Bonnet
 */
interface IPausable {

    /**
     * Returns whether the implementing contract is 
     * currently paused or not
     *
     * @return Whether the paused state is active
     */
    function isPaused() external view returns (bool);


    /**
     * Change the state to paused
     */
    function pause() external;


    /**
     * Change the state to resume, undo the effects 
     * of calling pause
     */
    function resume() external;
}