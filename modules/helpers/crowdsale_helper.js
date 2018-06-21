var BigNumber = require('bignumber.js')
var util = require('../util')
var config
var precision
var accounts

var getLog = async (contractInstance, transaction, event) => {
    var logs = await util.events.get(contractInstance, {
        event: event,
        transactionHash: transaction.receipt.transactionHash
    })
    return logs[0]
}

var _export = {
    setup: (_config, _precision) => {
        config = _config
        precision = _precision
    },
    events: {
        MemberAccountCreated: {
            getLog: async (contractInstance, transaction) => {
                return await getLog(contractInstance, transaction, 'MemberAccountCreated')
            }
        },
        ProxyCreated: {
            getLog: async (contractInstance, transaction) => {
                return await getLog(contractInstance, transaction, 'ProxyCreated')
            }
        },
        PoolCreated: {
            getLog: async (contractInstance, transaction) => {
                return await getLog(contractInstance, transaction, 'PoolCreated')
            }
        }
    },
    usesAuthentication: () => {
        return typeof config.crowdsale.authentication.whitelist === 'object'
    },
    getBeneficiary: () => {
        return config.crowdsale.stakes.stakeholders[0].account
    },
    getStakeholder: (options) => {
        let stakeholders = []
        for (let i = 0; i < config.crowdsale.stakes.stakeholders.length; i++) {
            let stakeholder = config.crowdsale.stakes.stakeholders[i]
            if ((typeof options.tokens == 'undefined' || (options.tokens && stakeholder.tokens > 0) || (!options.tokens && stakeholder.tokens === 0)) && 
                (typeof options.eth == 'undefined' || (options.eth && stakeholder.eth > 0) || (!options.eth && stakeholder.eth === 0)) && 
                (typeof options.contract == 'undefined' || (options.contract && typeof stakeholder.account === 'object') || (!options.contract && typeof stakeholder.account === 'string')) &&
                (typeof options.overwriteReleaseDate == 'undefined' || options.overwriteReleaseDate === stakeholder.overwriteReleaseDate)) {
                stakeholders.push(stakeholder)
            }
        }

        return stakeholders
    },
    getTokenValue: (rate, value, decimals) => {
        value = new BigNumber(value)
        let tokenPrecision = (new BigNumber(10)).pow(decimals)
        return value.mul(rate).mul(tokenPrecision).div(util.config.getWeiValue([1, 'ether']))
    },
    getRate: (phase, value) => {
        let rate = config.crowdsale.phases[phase].rate
        if (config.crowdsale.phases[phase].usesVolumeMultiplier && typeof value !== 'undefined') {
            let volumeMultiplier = _export.getVolumeMultiplier(value)
            if (null !== volumeMultiplier) {
                rate = rate + rate * volumeMultiplier.rate / precision
            }
        }

        return rate
    },
    getVolumeMultiplier: (volume) => {
        for (let i = config.crowdsale.volumeMultipliers.length; i > 0; i--) {
            let volumeMultiplier = config.crowdsale.volumeMultipliers[i - 1]
            volume = new BigNumber(volume)
            if (volume.gte(util.config.getWeiValue(volumeMultiplier.threshold))) {
                return volumeMultiplier
            }
        }

       return null;
    },
    presale: {
        getDuration: () => {
            let duration = 0;
            let phases = _export.presale.getPhases()
            for (let i = 0; i < phases.length; i++) {
                duration += util.config.getDurationValue(phases[i].duration)
            }

            return duration
        },
        getStartingPhaseIndex: () => {
            return 0
        },
        getStartingPhase: () => {
            return config.crowdsale.phases[0]
        },
        hasTransitionPhase: () => {
            return null !== _export.presale.getTransitionPhase()
        },
        getTransitionPhase: () => {
            let phases = _export.presale.getPhases()
            if (phases.length > 0 && phases[phases.length - 1].rate === 0) {
                return phases[phases.length - 1]
            }
            
            return null;
        },
        getPhases: () => {
            return config.crowdsale.phases.slice(
                0, _export.publicsale.getStartingPhaseIndex())
        },
        getRate: (phase, value) => {
            return _export.getRate(phase, value)
        }
    },
    publicsale: {
        getDuration: () => {
            let duration = 0;
            let phases = _export.publicsale.getPhases()
            for (let i = 0; i < phases.length; i++) {
                duration += util.config.getDurationValue(phases[i].duration)
            }

            return duration
        },
        getStartingPhaseIndex: () => {
            for (let i = 1; i < config.crowdsale.phases.length; i++) {
                if (config.crowdsale.phases[i].rate > 0) {
                    return i;
                }
            }
        },
        getStartingPhase: () => {
            return config.crowdsale.phases[0]
        },
        getPhases: () => {
            return config.crowdsale.phases.slice(
                _export.publicsale.getStartingPhaseIndex())
        },
        getRate: (phase, value) => {
            return _export.getRate(
                _export.publicsale.getStartingPhaseIndex() + phase, value)
        }
    }
}

module.exports = _export