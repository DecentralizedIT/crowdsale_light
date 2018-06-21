module.exports = {
    network: {
        test: {
            precision: 4, // Amount of decimals
            token: {
                contract: 'ProxyToken',
                burner: {
                    contract: 'ProxyTokenBurner'
                }
            },
            crowdsale: {
                contract: 'ProxyCrowdsale',
                baseRate: 1000,
                authentication: {
                    node: 0, // accounts[0]
                    whitelist: {
                        require: true
                    }
                },
                accounts: {
                    lock: {
                        stake: [100, 'finney'],
                        duration: [30, 'minutes'],
                        nodes: [
                            {
                                account: 0, // Account zero is used as a node when testing to ommit locking
                                enabled: true
                            }
                        ]
                    }
                },
                presale: {
                    start: 'Jul 1, 2018 12:00:00 GMT+0000',
                    soft: [500, 'ether'],
                    hard: [5882, 'ether'],
                    accepted: [500, 'finney']
                },
                publicsale: {
                    start: 'Aug 1, 2018 12:00:00 GMT+0000',
                    soft: [1000, 'ether'],
                    hard: [7058, 'ether'],
                    accepted: [40, 'finney']
                },
                phases: [{
                    duration: [16, 'days'], // Presale
                    rate: 1000,
                    lockupPeriod: [30, 'days'],
                    usesVolumeMultiplier: true
                }, {
                    duration: [15, 'days'], // Break
                    rate: 0,
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [1, 'days'], // First day
                    rate: 1400, // 40% 
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // First week
                    rate: 1250, // 25%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Second week
                    rate: 1150, // 15%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Third week
                    rate: 1100, // 10%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Last week
                    rate: 1050, // 5%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }],
                volumeMultipliers: [{
                    rate: 4000, // 1:700
                    lockupPeriod: 0,
                    threshold: [1, 'ether']
                }, {
                    rate: 4500, // 1:725
                    lockupPeriod: 0,
                    threshold: [30, 'ether']
                }, {
                    rate: 5000, // 1:750
                    lockupPeriod: 5000,
                    threshold: [100, 'ether']
                }, {
                    rate: 5500, // 1:775
                    lockupPeriod: 10000,
                    threshold: [500, 'ether']
                }, {
                    rate: 6000, // 1:800
                    lockupPeriod: 15000,
                    threshold: [1000, 'ether']
                }, {
                    rate: 6500, // 1:825
                    lockupPeriod: 20000,
                    threshold: [2500, 'ether']
                }],
                stakes: {
                    stakeholders: [{
                        account: 0, // Beneficiary 
                        tokens: 0,
                        eth: 7000,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: 1, // Founders
                        tokens: 1000,
                        eth: 0,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: 2, // Marketing 1
                        tokens: 750,
                        eth: 1000,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: 3, // Marketing 2
                        tokens: 750,
                        eth: 1000,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: 4, // Marketing 3
                        tokens: 750,
                        eth: 1000,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: 5, // Wings.ai community
                        tokens: 200,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }, {
                        account: 6,
                        tokens: 500,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }],
                    tokenReleasePhases: [{
                        percentage: 2500,
                        vestingPeriod: [90, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [180, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [270, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [360, 'days']
                    }]
                }
            }
        }, 
        rinkeby: {
            precision: 4, // Amount of decimals
            token: {
                contract: 'MyToken',
                burner: {
                    contract: 'MyTokenBurner'
                }
            },
            crowdsale: {
                contract: 'MyCrowdsale',
                baseRate: 500,
                authentication: {
                    authentication: {
                        node: 0, // Executing address
                        whitelist: {
                            require: true
                        }
                    }
                },
                accounts: {
                    lock: {
                        stake: [100, 'finney'],
                        duration: [30, 'minutes'],
                        nodes: [
                            {
                                account: 0, // Account zero is used as a node when testing to ommit locking
                                enabled: true
                            }
                        ]
                    }
                },
                presale: {
                    start: 'Jul 1, 2018 12:00:00 GMT+0000',
                    soft: [500, 'ether'],
                    hard: [5882, 'ether'],
                    accepted: [500, 'finney']
                },
                publicsale: {
                    start: 'Aug 1, 2018 12:00:00 GMT+0000',
                    soft: [1000, 'ether'],
                    hard: [7058, 'ether'],
                    accepted: [40, 'finney']
                },
                phases: [{
                    duration: [16, 'days'], // Presale
                    rate: 500,
                    lockupPeriod: [30, 'days'],
                    usesVolumeMultiplier: true
                }, {
                    duration: [15, 'days'], // Break
                    rate: 0,
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [1, 'days'], // First day
                    rate: 700, // 40% 
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // First week
                    rate: 625, // 25%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Second week
                    rate: 575, // 15%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Third week
                    rate: 550, // 10%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Last week
                    rate: 525, // 5%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }],
                volumeMultipliers: [{
                    rate: 4000, // 1:700
                    lockupPeriod: 0,
                    threshold: [1, 'ether']
                }, {
                    rate: 4500, // 1:725
                    lockupPeriod: 0,
                    threshold: [30, 'ether']
                }, {
                    rate: 5000, // 1:750
                    lockupPeriod: 5000,
                    threshold: [100, 'ether']
                }, {
                    rate: 5500, // 1:775
                    lockupPeriod: 10000,
                    threshold: [500, 'ether']
                }, {
                    rate: 6000, // 1:800
                    lockupPeriod: 15000,
                    threshold: [1000, 'ether']
                }, {
                    rate: 6500, // 1:825
                    lockupPeriod: 20000,
                    threshold: [2500, 'ether']
                }],
                stakes: {
                    stakeholders: [{
                        account: '', // Beneficiary (multisig)
                        tokens: 0,
                        eth: 10000,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // Founders
                        tokens: 1000,
                        eth: 0,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // Operations, team and bounty
                        tokens: 1200,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // Wings.ai community
                        tokens: 200,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // DCORP investors 
                        tokens: 100,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }],
                    tokenReleasePhases: [{
                        percentage: 2500,
                        vestingPeriod: [90, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [180, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [270, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [360, 'days']
                    }]
                }
            }
        },
        main: {
            precision: 4, // Amount of decimals
            token: {
                contract: 'MyToken',
                burner: {
                    contract: 'MyTokenBurner'
                }
            },
            crowdsale: {
                contract: 'MyCrowdsale',
                baseRate: 500,
                authentication: {
                    authentication: {
                        node: 0, // Executing address
                        whitelist: {
                            require: true
                        }
                    }
                },
                accounts: {
                    lock: {
                        stake: [100, 'finney'],
                        duration: [30, 'minutes'],
                        nodes: [
                            {
                                account: '',
                                enabled: true
                            }
                        ]
                    }
                },
                presale: {
                    start: 'Jul 1, 2018 12:00:00 GMT+0000',
                    soft: [500, 'ether'],
                    hard: [5882, 'ether'],
                    accepted: [500, 'finney']
                },
                publicsale: {
                    start: 'Aug 1, 2018 12:00:00 GMT+0000',
                    soft: [1000, 'ether'],
                    hard: [7058, 'ether'],
                    accepted: [40, 'finney']
                },
                phases: [{
                    duration: [16, 'days'], // Presale
                    rate: 500,
                    lockupPeriod: [30, 'days'],
                    usesVolumeMultiplier: true
                }, {
                    duration: [15, 'days'], // Break
                    rate: 0,
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [1, 'days'], // First day
                    rate: 700, // 40% 
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // First week
                    rate: 625, // 25%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Second week
                    rate: 575, // 15%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Third week
                    rate: 550, // 10%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }, {
                    duration: [7, 'days'], // Last week
                    rate: 525, // 5%
                    lockupPeriod: 0,
                    usesVolumeMultiplier: false
                }],
                volumeMultipliers: [{
                    rate: 4000, // 1:700
                    lockupPeriod: 0,
                    threshold: [1, 'ether']
                }, {
                    rate: 4500, // 1:725
                    lockupPeriod: 0,
                    threshold: [30, 'ether']
                }, {
                    rate: 5000, // 1:750
                    lockupPeriod: 5000,
                    threshold: [100, 'ether']
                }, {
                    rate: 5500, // 1:775
                    lockupPeriod: 10000,
                    threshold: [500, 'ether']
                }, {
                    rate: 6000, // 1:800
                    lockupPeriod: 15000,
                    threshold: [1000, 'ether']
                }, {
                    rate: 6500, // 1:825
                    lockupPeriod: 20000,
                    threshold: [2500, 'ether']
                }],
                stakes: {
                    stakeholders: [{
                        account: '', // Beneficiary (multisig)
                        tokens: 0,
                        eth: 10000,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // Founders
                        tokens: 1000,
                        eth: 0,
                        overwriteReleaseDate: false,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // Operations, team and bounty
                        tokens: 1200,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // Wings.ai community
                        tokens: 200,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }, {
                        account: '', // DCORP investors 
                        tokens: 100,
                        eth: 0,
                        overwriteReleaseDate: true,
                        fixedReleaseDate: 0
                    }],
                    tokenReleasePhases: [{
                        percentage: 2500,
                        vestingPeriod: [90, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [180, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [270, 'days']
                    }, {
                        percentage: 2500,
                        vestingPeriod: [360, 'days']
                    }]
                }
            }
        }
    }
}
  