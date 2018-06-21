var HDWalletProvider = require("truffle-hdwallet-provider")
var fs = require('fs')
var secret = fs.readFileSync(__dirname + "/.secret", 'utf8')

module.exports = {
  networks: {
    test: {
      host: "localhost",
      port: 8545,
      gas: 6500000,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      gas: 6500000,
      network_id: 4, // Rinkeby Ethereum network 
      provider: function () {
        var config = JSON.parse(secret).rinkeby
        return new HDWalletProvider(config.mnemonic, config.uri)
      }
    },
    main: {
      gas: 6500000,
      network_id: 1, // Official Ethereum network 
      provider: function () {
        var config = JSON.parse(secret).main
        return new HDWalletProvider(config.mnemonic, config.uri)
      }
    }
  },
  solc: {
		optimizer: {
			enabled: true,
			runs: 200
		}
	}
}
