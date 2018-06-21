pragma solidity ^0.4.24;

import "./IMemberAccountShared.sol";
import "../../token/IToken.sol";
import "../../../infrastructure/ownership/TransferableOwnership.sol";

/**
 * MemberAccountShared 
 *
 * FlyWeight - Shared data to reduce the memory
 * footprint of the member account contracts
 *
 * #created 12/06/2018
 * #author Frank Bonnet
 */
contract MemberAccountShared is TransferableOwnership, IMemberAccountShared {

    struct Lock {
        address owner;
        uint128 until;
        uint128 stake;
    }

    struct Node {
        bool enabled;
        uint64 index;
    }

    // Nodes
    mapping(address => Node) private nodes;
    address[] private nodesIndex;

    // Auth
    uint public lockStake;
    uint public lockDuration;
    mapping(address => Lock) private locks;

    // Targets
    address public targetCrowdsale;
    address public targetToken;


    // Events
    event NodeAdded(address node, bool enabled);
    event NodeUpdated(address node, bool enabled);


    /**
     * Construct shared data - FlyWeight
     *
     * @param _targetCrowdsale Target crowdsale to invest in
     * @param _targetToken Token that is bought
     * @param _lockStake Min amount of wei required to obtain a lock
     * @param _lockDuration Time that a lock is valid
     */
    constructor(address _targetCrowdsale, address _targetToken, uint _lockStake, uint _lockDuration) public {
        targetCrowdsale = _targetCrowdsale;
        targetToken = _targetToken;
        lockStake = _lockStake;
        lockDuration = _lockDuration;
    }


    /**
     * Returns the address of the crowdsale contract that 
     * is being targeted
     *
     * @return Crowdsale address
     */
    function getTargetCrowdsale() public view returns (address) {
        return targetCrowdsale;
    }


    /**
     * Returns the address of the ERC20 Token contract that 
     * is being targeted
     *
     * @return Token address
     */
    function getTargetToken() public view returns (address) {
        return targetToken;
    }


    /**
     * Sets the stake needed to obtain a lock to `_value` wei
     *
     * @param _value Stake needed to obtain a lock
     */
    function setLockStake(uint _value) public only_owner {
        lockStake = _value;
    }


    /**
     * Set the time that a lock is valid to `_value`
     *
     * @param _value Time that a lock is valid
     */
    function setLockDuration(uint _value) public only_owner {
        lockDuration = _value;
    }


    /**
     * Returns true if `_account` is locked currently. A locked account 
     * restricts authentication to the lock owner and can be overwritten 
     * by a valid node or enabled 2fa option
     *
     * @param _account Account that is locked or not
     * @return Wether the account is locked or not
     */
    function isLocked(address _account) public view returns (bool) {
        return locks[_account].until >= now;
    }


    /**
     * Returns the lock data for `_account`. The lock data includes the 
     * lock owner, the expiry time and the received stake
     *
     * @param _account Account for which to retreive the lock data
     * @return Lock owner, expiry time, received stake
     */
    function getLock(address _account) public view returns (address, uint, uint) {
        Lock storage lock = locks[_account];
        return (lock.owner, lock.until, lock.stake); 
    }


    /**
     * Obtain a lock on `_account`. Locking the account restricts authentication 
     * to the msg.sender and can be overwritten by a valid node or enabled 2fa option
     *
     * @param _account Account that will be locked
     */
    function lock(address _account) public payable {
        lockFor(_account, msg.sender);
    } 


    /**
     * Obtain a lock on `_account` for `_owner`. Locking the account restricts authentication 
     * to the `_owner` and can be overwritten by a valid node or enabled 2fa option
     *
     * @param _account Account that will be locked
     * @param _owner The owner of the lock
     */
    function lockFor(address _account, address _owner) public payable {
        require(locks[_account].until < now); // Not currently locked

        // Handle stake (nodes are ommited)
        if (msg.sender != _owner || !nodes[msg.sender].enabled) {
            require(msg.value >= lockStake); // Sufficient stake

            // Return stake to account
            _account.transfer(msg.value); 
        }

        // Obtain lock
        locks[_account] = Lock(
            _owner, uint128(now + lockDuration), uint128(msg.value));
    }


    /**
     * Remove a lock from `_account`. Locking the account restricts authentication 
     * to the msg.sender
     */
    function removeLock() public {

        // Remove lock
        locks[msg.sender].until = 0;
    } 


    /**
     * Adds `_node` to the nodes list. Nodes in the node list 
     * are trusted and thus not required to obtain a lock before 
     * authenticating. This saves gas.
     *
     * @param _node Address to be removed as a valid node
     * @param _enabled Whether the node is enabled or not
     */
    function addNode(address _node, bool _enabled) public only_owner {
        require(nodesIndex.length == 0 || _node != nodesIndex[nodes[_node].index]);

        // Add node
        nodes[_node] = Node(
            _enabled,  uint64(nodesIndex.push(_node) - 1));

        // Notify
        emit NodeAdded(_node, _enabled);
    }


    /**
     * Updates a `_node` from the nodes list
     *
     * @param _node Address to be removed as a valid node
     * @param _enabled Whether the node is enabled or not
     */
    function updateNode(address _node, bool _enabled) public only_owner {
        require(nodesIndex.length > 0 && _node == nodesIndex[nodes[_node].index]);

        // Update node
        Node storage node = nodes[_node];
        node.enabled = _enabled;

        // Notify
        emit NodeUpdated(_node, _enabled);
    }


    /**
     * Returns true if `_node` is a valid node
     *
     * @param _node The address to be checked
     * @return Wether _node is a valid node
     */
    function isNode(address _node) public view returns (bool) {
        return nodes[_node].enabled;
    }
}