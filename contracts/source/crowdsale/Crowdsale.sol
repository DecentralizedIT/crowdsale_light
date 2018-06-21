pragma solidity ^0.4.24;

import "./ICrowdsale.sol";
import "../token/IToken.sol";
import "../token/IManagedToken.sol";
import "../../infrastructure/ownership/MultiOwned.sol";

/**
 * Crowdsale
 *
 * Abstract base crowdsale contract that manages the sale of 
 * an ERC20 token
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract Crowdsale is ICrowdsale, MultiOwned {

    enum Stages {
        Deploying,
        Deployed,
        InProgress,
        Ended
    }

    struct Balance {
        uint128 eth;
        uint128 tokens;
        uint index;
    }

    struct Percentage {
        bool overwriteReleaseDate;
        uint32 eth;
        uint32 tokens;
        uint64 fixedReleaseDate;
        uint128 index; 
    }

    struct Payout {
        uint64 percentage;
        uint64 vestingPeriod;
    }

    struct Phase {
        uint32 rate;
        uint64 end;
        uint64 bonusReleaseDate;
        bool useVolumeMultiplier;
    }

    struct VolumeMultiplier {
        uint32 rateMultiplier;
        uint32 bonusReleaseDateMultiplier;
    }

    // Crowdsale details
    uint public baseRate;
    uint public minAmount; 
    uint public maxAmount; 
    uint public minAcceptedAmount;
    uint public minAmountPresale; 
    uint public maxAmountPresale;
    uint public minAcceptedAmountPresale;

    // Company address
    address public beneficiary; 

    // Denominators
    uint internal percentageDenominator;
    uint internal tokenDenominator;

    // Crowdsale state
    uint public start;
    uint public presaleEnd;
    uint public crowdsaleEnd;
    uint public raised;
    uint public allocatedEth;
    uint public allocatedTokens;
    Stages public stage;

    // Token contract
    IManagedToken public token;

    // Refundable ether 
    mapping (address => uint) private refundable;

    // Alocated balances
    mapping (address => mapping(uint64 => Balance)) private allocated;
    mapping(address => uint64[]) private allocatedIndex;

    // Stakeholders
    mapping (address => Percentage) private stakeholderPercentages;
    address[] private stakeholderPercentagesIndex;
    Payout[] private stakeholdersPayouts;

    // Crowdsale phases
    Phase[] private phases;

    // Volume multipliers
    mapping (uint => VolumeMultiplier) private volumeMultipliers;
    uint[] private volumeMultiplierThresholds;

    
    /**
     * Throw if at stage other than current stage
     * 
     * @param _stage expected stage to test for
     */
    modifier at_stage(Stages _stage) {
        require(stage == _stage);
        _;
    }


    /**
     * Only after crowdsaleEnd plus `_time`
     * 
     * @param _time Time to pass
     */
    modifier only_after(uint _time) {
        require(now > crowdsaleEnd + _time);
        _;
    }


    /**
     * Only after crowdsale
     */
    modifier only_after_crowdsale() {
        require(now > crowdsaleEnd);
        _;
    }


    /**
     * Throw if sender is not beneficiary
     */
    modifier only_beneficiary() {
        require(beneficiary == msg.sender);
        _;
    }


    /**
     * Start in the deploying stage
     */
    constructor() public {
        stage = Stages.Deploying;
    }


    /**
     * Setup the crowdsale
     *
     * @param _start The timestamp of the start date
     * @param _token The token that is sold
     * @param _tokenDenominator The token amount of decimals that the token uses
     * @param _percentageDenominator The percision of percentages
     * @param _minAmountPresale The min cap for the presale
     * @param _maxAmountPresale The max cap for the presale
     * @param _minAcceptedAmountPresale The lowest accepted amount during the presale phase
     * @param _minAmount The min cap for the ICO
     * @param _maxAmount The max cap for the ICO
     * @param _minAcceptedAmount The lowest accepted amount during the ICO phase
     */
    function setup(uint _start, address _token, uint _tokenDenominator, uint _percentageDenominator, uint _minAmountPresale, uint _maxAmountPresale, uint _minAcceptedAmountPresale, uint _minAmount, uint _maxAmount, uint _minAcceptedAmount) public only_owner at_stage(Stages.Deploying) {
        token = IManagedToken(_token);
        tokenDenominator = _tokenDenominator;
        percentageDenominator = _percentageDenominator;
        start = _start;
        minAmountPresale = _minAmountPresale;
        maxAmountPresale = _maxAmountPresale;
        minAcceptedAmountPresale = _minAcceptedAmountPresale;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        minAcceptedAmount = _minAcceptedAmount;
    }


    /**
     * Setup rates and phases
     *
     * @param _baseRate The rate without bonus
     * @param _phaseRates The rates for each phase
     * @param _phasePeriods The periods that each phase lasts (first phase is the presale phase)
     * @param _phaseBonusLockupPeriods The lockup period that each phase lasts
     * @param _phaseUsesVolumeMultiplier Wheter or not volume bonusses are used in the respective phase
     */
    function setupPhases(uint _baseRate, uint32[] _phaseRates, uint64[] _phasePeriods, uint64[] _phaseBonusLockupPeriods, bool[] _phaseUsesVolumeMultiplier) public only_owner at_stage(Stages.Deploying) {
        baseRate = _baseRate;
        presaleEnd = start + _phasePeriods[0]; // First phase is expected to be the presale phase
        crowdsaleEnd = start; // Plus the sum of the rate phases

        for (uint i = 0; i < _phaseRates.length; i++) {
            crowdsaleEnd += _phasePeriods[i];
            phases.push(Phase(
                _phaseRates[i], 
                uint64(crowdsaleEnd), 
                _phaseBonusLockupPeriods[i] > 0 ? uint64(crowdsaleEnd) + _phaseBonusLockupPeriods[i] : 0, 
                _phaseUsesVolumeMultiplier[i]));
        }
    }


    /**
     * Setup stakeholders
     *
     * @param _stakeholders The addresses of the stakeholders (first stakeholder is the beneficiary)
     * @param _stakeholderEthPercentages The eth percentages of the stakeholders
     * @param _stakeholderTokenPercentages The token percentages of the stakeholders
     * @param _stakeholderTokenPayoutOverwriteReleaseDates Wheter the vesting period is overwritten for the respective stakeholder
     * @param _stakeholderTokenPayoutFixedReleaseDates The vesting period after which the whole percentage of the tokens is released to the respective stakeholder
     * @param _stakeholderTokenPayoutPercentages The percentage of the tokens that is released at the respective date
     * @param _stakeholderTokenPayoutVestingPeriods The vesting period after which the respective percentage of the tokens is released
     */
    function setupStakeholders(address[] _stakeholders, uint32[] _stakeholderEthPercentages, uint32[] _stakeholderTokenPercentages, bool[] _stakeholderTokenPayoutOverwriteReleaseDates, uint64[] _stakeholderTokenPayoutFixedReleaseDates, uint64[] _stakeholderTokenPayoutPercentages, uint64[] _stakeholderTokenPayoutVestingPeriods) public only_owner at_stage(Stages.Deploying) {
        beneficiary = _stakeholders[0]; // First stakeholder is expected to be the beneficiary
        for (uint128 i = 0; i < _stakeholders.length; i++) {
            stakeholderPercentagesIndex.push(_stakeholders[i]);
            stakeholderPercentages[_stakeholders[i]] = Percentage(
                _stakeholderTokenPayoutOverwriteReleaseDates[i],
                _stakeholderEthPercentages[i], 
                _stakeholderTokenPercentages[i], 
                _stakeholderTokenPayoutFixedReleaseDates[i], i);
        }

        // Percentages add up to 100
        for (uint ii = 0; ii < _stakeholderTokenPayoutPercentages.length; ii++) {
            stakeholdersPayouts.push(Payout(_stakeholderTokenPayoutPercentages[ii], _stakeholderTokenPayoutVestingPeriods[ii]));
        }
    }

    
    /**
     * Setup volume multipliers
     *
     * @param _volumeMultiplierRates The rates will be multiplied by this value (denominated by 4)
     * @param _volumeMultiplierLockupPeriods The lockup periods will be multiplied by this value (denominated by 4)
     * @param _volumeMultiplierThresholds The volume thresholds for each respective multiplier
     */
    function setupVolumeMultipliers(uint32[] _volumeMultiplierRates, uint32[] _volumeMultiplierLockupPeriods, uint[] _volumeMultiplierThresholds) public only_owner at_stage(Stages.Deploying) {
        require(phases.length > 0);
        volumeMultiplierThresholds = _volumeMultiplierThresholds;
        for (uint i = 0; i < volumeMultiplierThresholds.length; i++) {
            volumeMultipliers[volumeMultiplierThresholds[i]] = VolumeMultiplier(_volumeMultiplierRates[i], _volumeMultiplierLockupPeriods[i]);
        }
    }
    

    /**
     * After calling the deploy function the crowdsale
     * rules become immutable 
     */
    function deploy() public only_owner at_stage(Stages.Deploying) {
        require(phases.length > 0);
        require(stakeholderPercentagesIndex.length > 0);
        stage = Stages.Deployed;
    }


    /**
     * Prove that beneficiary is able to sign transactions 
     * and start the crowdsale
     */
    function startCrowdsale() external only_beneficiary at_stage(Stages.Deployed) {
        stage = Stages.InProgress;
    }


    /**
     * Returns true if the contract is currently in the presale phase
     *
     * @return True if in presale phase
     */
    function isInPresalePhase() external view returns (bool) {
        return _isInPresalePhase();
    }


    /**
     * Returns true if the contract is currently in the presale phase
     *
     * @return True if in presale phase
     */
    function _isInPresalePhase() internal view returns (bool) {
        return stage == Stages.InProgress && now >= start && now <= presaleEnd;
    }


    /**
     * Returns true if the contract is currently in the ended stage
     *
     * @return True if ended
     */
    function isEnded() external view returns (bool) {
        return stage == Stages.Ended;
    }


    /**
     * Gets the amount of release dates for `_beneficiary` at which 
     * balances are released
     * 
     * @param _beneficiary The account that the balances are allocated for
     * @return Amount of release dates
     */
    function getReleaseDateCount(address _beneficiary) external view returns (uint) {
        return allocatedIndex[_beneficiary].length;
    }


    /**
     * Gets the release date for `_beneficiary` at `_index` at which a 
     * balance is released
     * 
     * @param _beneficiary The account that the balance is allocated for
     * @param _index Index of the release date
     * @return Release date
     */
    function getReleaseDateAtIndex(address _beneficiary, uint64 _index) external view returns (uint64) {
        return allocatedIndex[_beneficiary][_index];
    }


    /**
     * Returns true if `_beneficiary` has a balance allocated
     *
     * @param _beneficiary The account that the balance is allocated for
     * @param _releaseDate The date after which the balance can be withdrawn
     * @return True if there is a balance that belongs to `_beneficiary` at `_releaseDate`
     */
    function _hasAllocatedBalanceAtReleaseDate(address _beneficiary, uint64 _releaseDate) internal view returns (bool) {
        return allocatedIndex[_beneficiary].length > 0 && _releaseDate == allocatedIndex[_beneficiary][allocated[_beneficiary][_releaseDate].index];
    }


    /**
     * Get the allocated token and ether balance of `_beneficiary` at `_releaseDate`
     *
     * @param _beneficiary The account that the balance is allocated for
     * @param _releaseDate The date after which the balance can be withdrawn
     * @return allocated ether balance, allocated token balance
     */
    function getAllocatedBalanceAtReleaseDate(address _beneficiary, uint64 _releaseDate) external view returns (uint, uint) {
        Balance memory balance = allocated[_beneficiary][_releaseDate];
        return (balance.eth, balance.tokens);
    }


    /** 
     * Get the allocated token and ether balance of `_beneficiary` without taking release dates into account
     * 
     * @param _beneficiary The address from which the allocated balance will be retrieved
     * @return allocated ether balance, allocated token balance
     */
    function getAllocatedBalance(address _beneficiary) external view returns (uint, uint) {
        uint ethBalance = 0;
        uint allocatedTokenBalance = 0;

        // Sum allocated balances
        for (uint i = 0; i < allocatedIndex[_beneficiary].length; i++) {
            Balance memory balance = allocated[_beneficiary][allocatedIndex[_beneficiary][i]];
            ethBalance += balance.eth;
            allocatedTokenBalance += balance.tokens;
        }

        return (ethBalance, allocatedTokenBalance);
    }


    /** 
     * Get the refundable ether balance of `_beneficiary`
     * 
     * @param _beneficiary The address from which the balance will be retrieved
     * @return refunable ether balance
     */
    function getRefundableBalance(address _beneficiary) external view returns (uint) {
        return now > crowdsaleEnd && raised < minAmount ? refundable[_beneficiary] : 0;
    }


    /**
     * Returns the current phase based on the current time
     *
     * @return The index of the current phase
     */
    function getCurrentPhase() external view returns (uint) {
        return _getCurrentPhase();
    }


    /**
     * Returns the current phase based on the current time
     *
     * @return The index of the current phase
     */
    function _getCurrentPhase() internal view returns (uint) {
        for (uint i = 0; i < phases.length; i++) {
            if (now <= phases[i].end) {
                return i;
                break;
            }
        }

        return uint(-1); // Does not exist (underflow)
    }


    /**
     * Returns the rate and bonus release date
     *
     * @param _phase The phase to use while determining the rate
     * @param _volume The amount wei used to determin what volume multiplier to use
     * @return The rate used in `_phase` multiplied by the corresponding volume multiplier
     */
    function getRate(uint _phase, uint _volume) external view returns (uint) {
        return _getRate(_phase, _volume);
    }


    /**
     * Returns the rate and bonus release date
     *
     * @param _phase The phase to use while determining the rate
     * @param _volume The amount wei used to determin what volume multiplier to use
     * @return The rate used in `_phase` multiplied by the corresponding volume multiplier
     */
    function _getRate(uint _phase, uint _volume) internal view returns (uint) {
        uint rate = 0;
        if (stage == Stages.InProgress && now >= start) {
            Phase storage phase = phases[_phase];
            rate = phase.rate;

            // Find volume multiplier
            if (phase.useVolumeMultiplier && volumeMultiplierThresholds.length > 0 && _volume >= volumeMultiplierThresholds[0]) {
                for (uint i = volumeMultiplierThresholds.length; i > 0; i--) {
                    if (_volume >= volumeMultiplierThresholds[i - 1]) {
                        VolumeMultiplier storage multiplier = volumeMultipliers[volumeMultiplierThresholds[i - 1]];
                        rate += phase.rate * multiplier.rateMultiplier / percentageDenominator;
                        break;
                    }
                }
            }
        }
        
        return rate;
    }


    /**
     * Get distribution data based on the current phase and 
     * the volume in wei that is being distributed
     * 
     * @param _phase The current crowdsale phase
     * @param _volume The amount wei used to determine what volume multiplier to use
     * @return Volumes and corresponding release dates
     */
    function getDistributionData(uint _phase, uint _volume) internal view returns (uint[], uint64[]) {
        Phase storage phase = phases[_phase];
        uint remainingVolume = _volume;

        bool usingMultiplier = false;
        uint[] memory volumes = new uint[](1);
        uint64[] memory releaseDates = new uint64[](1);

        // Find volume multipliers
        if (phase.useVolumeMultiplier && volumeMultiplierThresholds.length > 0 && _volume >= volumeMultiplierThresholds[0]) {
            uint phaseReleasePeriod = phase.bonusReleaseDate - crowdsaleEnd;
            for (uint i = volumeMultiplierThresholds.length; i > 0; i--) {
                if (_volume >= volumeMultiplierThresholds[i - 1]) {
                    if (!usingMultiplier) {
                        volumes = new uint[](i + 1);
                        releaseDates = new uint64[](i + 1);
                        usingMultiplier = true;
                    }

                    VolumeMultiplier storage multiplier = volumeMultipliers[volumeMultiplierThresholds[i - 1]];
                    releaseDates[i] = uint64(phase.bonusReleaseDate + phaseReleasePeriod * multiplier.bonusReleaseDateMultiplier / percentageDenominator);
                    volumes[i] = remainingVolume - volumeMultiplierThresholds[i - 1];

                    remainingVolume -= volumes[i];
                }
            }
        }

        // Store increment
        volumes[0] = remainingVolume;
        releaseDates[0] = phase.bonusReleaseDate;

        return (volumes, releaseDates);
    }


    /**
     * Convert `_wei` to an amount in tokens using 
     * the `_rate`
     *
     * @param _wei amount of wei to convert
     * @param _rate rate to use for the conversion
     * @return Amount in tokens
     */
    function toTokens(uint _wei, uint _rate) external view returns (uint) {
        return _toTokens(_wei, _rate);
    }


    /**
     * Convert `_wei` to an amount in tokens using 
     * the `_rate`
     *
     * @param _wei amount of wei to convert
     * @param _rate rate to use for the conversion
     * @return Amount in tokens
     */
    function _toTokens(uint _wei, uint _rate) internal view returns (uint) {
        return _wei * _rate * tokenDenominator / 1 ether;
    }


    /**
     * Receive Eth and issue tokens to the sender
     * 
     * This function requires that msg.sender is not a contract. This is required because it's 
     * not possible for a contract to specify a gas amount when calling the (internal) send() 
     * function. Solidity imposes a maximum amount of gas (2300 gas at the time of writing)
     * 
     * Contracts can call the contribute() function instead
     */
    function () external payable {
        require(msg.sender == tx.origin);
        _handleTransaction(msg.sender, msg.value);
    }


    /**
     * Receive ether and issue tokens to the sender
     *
     * @return The accepted ether amount
     */
    function contribute() external payable returns (uint) {
        return _handleTransaction(msg.sender, msg.value);
    }


    /**
     * Receive ether and issue tokens to `_beneficiary`
     *
     * @param _beneficiary The account that receives the tokens
     * @return The accepted ether amount
     */
    function contributeFor(address _beneficiary) external payable returns (uint) {
        return _handleTransaction(_beneficiary, msg.value);
    }


    /**
     * Function to end the crowdsale by setting 
     * the stage to Ended
     */
    function endCrowdsale() external at_stage(Stages.InProgress) {
        require(now > crowdsaleEnd || raised >= maxAmount);
        require(raised >= minAmount);
        stage = Stages.Ended;

        // Unlock token
        if (!token.unlock()) {
            revert();
        }

        // Allocate tokens (no allocation can be done after this period)
        uint totalTokenSupply = IToken(token).totalSupply() + allocatedTokens;
        for (uint i = 0; i < stakeholdersPayouts.length; i++) {
            Payout storage p = stakeholdersPayouts[i];
            _allocateStakeholdersTokens(totalTokenSupply * p.percentage / percentageDenominator, uint64(now + p.vestingPeriod));
        }

        // Allocate remaining ETH
        _allocateStakeholdersEth(address(this).balance - allocatedEth, 0);
    }


    /**
     * Withdraw allocated tokens
     */
    function withdrawTokens() external {
        _withdrawTokensTo(msg.sender);
    }


    /**
     * Withdraw allocated tokens
     *
     * @param _beneficiary Address to send to
     */
    function withdrawTokensTo(address _beneficiary) external {
        _withdrawTokensTo(_beneficiary);
    }


    /**
     * Withdraw allocated tokens
     *
     * @param _beneficiary Address to send to
     */
    function _withdrawTokensTo(address _beneficiary) internal {
        uint tokensToSend = 0;
        for (uint i = 0; i < allocatedIndex[msg.sender].length; i++) {
            uint64 releaseDate = allocatedIndex[msg.sender][i];
            if (releaseDate <= now) {
                Balance storage b = allocated[msg.sender][releaseDate];
                tokensToSend += b.tokens;
                b.tokens = 0;
            }
        }

        if (tokensToSend > 0) {
            allocatedTokens -= tokensToSend;
            if (!token.issue(_beneficiary, tokensToSend)) {
                revert();
            }
        }
    }


    /**
     * Withdraw allocated ether
     */
    function withdrawEther() external {
        _withdrawEtherTo(msg.sender);
    }


    /**
     * Withdraw allocated ether
     *
     * @param _beneficiary Address to send to
     */
    function withdrawEtherTo(address _beneficiary) external {
        _withdrawEtherTo(_beneficiary);
    }


    /**
     * Withdraw allocated ether
     *
     * @param _beneficiary Address to send to
     */
    function _withdrawEtherTo(address _beneficiary) internal {
        uint ethToSend = 0;
        for (uint i = 0; i < allocatedIndex[msg.sender].length; i++) {
            uint64 releaseDate = allocatedIndex[msg.sender][i];
            if (releaseDate <= now) {
                Balance storage b = allocated[msg.sender][releaseDate];
                ethToSend += b.eth;
                b.eth = 0;
            }
        }

        if (ethToSend > 0) {
            allocatedEth -= ethToSend;
            if (!_beneficiary.send(ethToSend)) {
                revert();
            }
        }
    }


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end of the crowdsale
     */
    function refund() external {
        _refundTo(msg.sender);
    }


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end of the crowdsale
     *
     * @param _beneficiary Address to send to
     */
    function refundTo(address _beneficiary) external {
        _refundTo(_beneficiary);
    }


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end of the crowdsale
     *
     * @param _beneficiary Address to send to
     */
    function _refundTo(address _beneficiary) internal only_after_crowdsale at_stage(Stages.InProgress) {
        require(raised < minAmount);

        uint receivedAmount = refundable[msg.sender];
        refundable[msg.sender] = 0;

        if (receivedAmount > 0 && !_beneficiary.send(receivedAmount)) {
            refundable[msg.sender] = receivedAmount;
        }
    }


    /**
     * Failsafe and clean-up mechanism
     */
    function destroy() public only_beneficiary only_after(500 days) {
        selfdestruct(beneficiary);
    }


    /**
     * Handle incoming transaction
     * 
     * @param _beneficiary Tokens are issued to this account
     * @param _received The amount that was received
     * @return The accepted ether amount
     */
    function _handleTransaction(address _beneficiary, uint _received) internal at_stage(Stages.InProgress) returns (uint) {
        require(now >= start && now <= crowdsaleEnd);
        require(isAcceptingContributions());
        require(isAcceptedContributor(_beneficiary));

        if (_isInPresalePhase()) {
            return _handlePresaleTransaction(
                _beneficiary, _received);
        } else {
            return _handlePublicsaleTransaction(
                _beneficiary, _received);
        }
    }


    /**
     * Handle incoming transaction during the presale phase
     * 
     * @param _beneficiary Tokens are issued to this account
     * @param _received The amount that was received
     * @return The accepted ether amount
     */
    function _handlePresaleTransaction(address _beneficiary, uint _received) private returns (uint) {
        require(_received >= minAcceptedAmountPresale);
        require(raised < maxAmountPresale);

        uint acceptedAmount;
        if (raised + _received > maxAmountPresale) {
            acceptedAmount = maxAmountPresale - raised;
        } else {
            acceptedAmount = _received;
        }

        raised += acceptedAmount;

        // During the presale phase - Non refundable
        _allocateStakeholdersEth(acceptedAmount, 0); 

        // Issue tokens
        _distributeTokens(_beneficiary, _received, acceptedAmount);
        return acceptedAmount;
    }


    /**
     * Handle incoming transaction during the publicsale phase
     * 
     * @param _beneficiary Tokens are issued to this account
     * @param _received The amount that was received
     * @return The accepted ether amount
     */
    function _handlePublicsaleTransaction(address _beneficiary, uint _received) private returns (uint) {
        require(_received >= minAcceptedAmount);
        require(raised >= minAmountPresale);
        require(raised < maxAmount);

        uint acceptedAmount;
        if (raised + _received > maxAmount) {
            acceptedAmount = maxAmount - raised;
        } else {
            acceptedAmount = _received;
        }

        raised += acceptedAmount;
        
        // During the public phase - 100% refundable
        refundable[_beneficiary] += acceptedAmount; 

        // Issue tokens
        _distributeTokens(_beneficiary, _received, acceptedAmount);
        return acceptedAmount;
    }


    /**
     * Distribute tokens 
     *
     * Tokens can be issued by instructing the token contract to create new tokens or by 
     * allocating tokens and instructing the token contract to create the tokens later
     * 
     * @param _beneficiary Tokens are issued to this account
     * @param _received The amount that was received
     * @param _acceptedAmount The amount that was accepted
     */
    function _distributeTokens(address _beneficiary, uint _received, uint _acceptedAmount) private {
        uint tokensToIssue = 0;
        uint phase = _getCurrentPhase();
        uint rate = _getRate(phase, _acceptedAmount);
        if (rate == 0) {
            revert(); // Paused phase
        }

        // Volume multipliers
        uint[] memory volumes;
        uint64[] memory releaseDates;
        (volumes, releaseDates) = getDistributionData(
            phase, _acceptedAmount);
        
        // Allocate tokens
        for (uint i = 0; i < volumes.length; i++) {
            uint tokensAtCurrentRate = _toTokens(volumes[i], rate);
            if (rate > baseRate && releaseDates[i] > now) {
                uint bonusTokens = tokensAtCurrentRate * (rate - baseRate) / rate;
                _allocateTokens(_beneficiary, uint128(bonusTokens), releaseDates[i]);

                tokensToIssue += tokensAtCurrentRate - bonusTokens;
            } else {
                tokensToIssue += tokensAtCurrentRate;
            }
        }

        // Issue tokens
        if (tokensToIssue > 0 && !token.issue(_beneficiary, tokensToIssue)) {
            revert();
        }

        // Refund due to max cap hit
        if (_received - _acceptedAmount > 0 && !_beneficiary.send(_received - _acceptedAmount)) {
            revert();
        }
    }


    /**
     * Allocate ETH
     *
     * @param _beneficiary The account to alocate the eth for
     * @param _amount The amount of ETH to allocate
     * @param _releaseDate The date after which the eth can be withdrawn
     */    
    function _allocateEth(address _beneficiary, uint128 _amount, uint64 _releaseDate) internal {
        if (_hasAllocatedBalanceAtReleaseDate(_beneficiary, _releaseDate)) {
            allocated[_beneficiary][_releaseDate].eth += _amount;
        } else {
            allocated[_beneficiary][_releaseDate] = Balance(
                _amount, 0, uint64(allocatedIndex[_beneficiary].push(_releaseDate) - 1));
        }

        allocatedEth += _amount;
    }


    /**
     * Allocate Tokens
     *
     * @param _beneficiary The account to allocate the tokens for
     * @param _amount The amount of tokens to allocate
     * @param _releaseDate The date after which the tokens can be withdrawn
     */    
    function _allocateTokens(address _beneficiary, uint128 _amount, uint64 _releaseDate) internal {
        if (_hasAllocatedBalanceAtReleaseDate(_beneficiary, _releaseDate)) {
            allocated[_beneficiary][_releaseDate].tokens += _amount;
        } else {
            allocated[_beneficiary][_releaseDate] = Balance(
                0, _amount, uint64(allocatedIndex[_beneficiary].push(_releaseDate) - 1));
        }

        allocatedTokens += _amount;
    }


    /**
     * Allocate ETH for stakeholders
     *
     * @param _amount The amount of ETH to allocate
     * @param _releaseDate The date after which the eth can be withdrawn
     */    
    function _allocateStakeholdersEth(uint _amount, uint64 _releaseDate) internal {
        for (uint i = 0; i < stakeholderPercentagesIndex.length; i++) {
            Percentage storage p = stakeholderPercentages[stakeholderPercentagesIndex[i]];
            if (p.eth > 0) {
                _allocateEth(
                    stakeholderPercentagesIndex[i], 
                    uint128(_amount * p.eth / percentageDenominator), 
                    _releaseDate);
            }
        }
    }


    /**
     * Allocate Tokens for stakeholders
     *
     * @param _amount The amount of tokens created
     * @param _releaseDate The date after which the tokens can be withdrawn (unless overwitten)
     */    
    function _allocateStakeholdersTokens(uint _amount, uint64 _releaseDate) internal {
        for (uint i = 0; i < stakeholderPercentagesIndex.length; i++) {
            Percentage storage p = stakeholderPercentages[stakeholderPercentagesIndex[i]];
            if (p.tokens > 0) {
                _allocateTokens(
                    stakeholderPercentagesIndex[i], 
                    uint128(_amount * p.tokens / percentageDenominator), 
                    p.overwriteReleaseDate ? p.fixedReleaseDate : _releaseDate);
            }
        }
    }


    /**
     * Allows the implementing contract to validate a 
     * contributing account
     *
     * @param _contributor Address that is being validated
     * @return Wheter the contributor is accepted or not
     */
    function isAcceptedContributor(address _contributor) internal view returns (bool);


    /**
     * Allows the implementing contract to prevent the accepting 
     * of contributions
     *
     * @return Wheter contributions are accepted or not
     */
    function isAcceptingContributions() internal view returns (bool);
}