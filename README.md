# Welcome to the generic crowdsale (light) and token repository

## Simple Summary
This generic crowdsale contains three different components.

The first (Token) is a standard component for ERC-20 compatible tokens that
allows for the implementation of a standard API for tokens within smart
contracts and provides basic functionality to transfer tokens, as well as
allow tokens to be approved so they can be spent by another on-chain third
party.

The second (ManagedToken) is a specialized component that adds adds additional 
functionalities to the ERC-20 token contract that allows the token to be managed 
after it has been published. This enables the owner(s) of the ERC-20 token contract 
to lock tokens, issue additional tokens or burn tokens after the token has been 
published. Only the addresses in the list of owners can choose to execute these 
functions and these owners are only be able to execute these functions under certain
conditions that are decided upon ahead of time.

The third (Crowdsale) is a specialized component to manage the
crowdsale of an ERC-20 token on the Ethereum blockchain. This component can
be used by any venture (also non-crypto related ventures) to raise funds in
a decentralized manner on the Ethereum blockchain.

The combination of these three components can for be used to let the crowdsale 
contract manage the token contract. Then, the crowdsale contract is the only one 
that is able to unlock, issue or burn tokens. It could be decided that the token 
will remain locked until the crowdsale has been completed successfully. Only when the
crowdsale has been completed successfully, can the crowdsale contract unlock the token. 
It is up to the initiator of the crowdsale contract to decide if the crowdsale 
contract will be owned by one or multiple parties.

## Preparing development environment

1. `git clone` this repository.
2. Install Docker. This is needed to run the Test RCP client in an isolated
   environment.
2. Install Node Package Manager (NPM). See [installation
   instructions](https://www.npmjs.com/get-npm)
3. Install the Solidity Compiler (`solc`). See [installation
   instructions](http://solidity.readthedocs.io/en/develop/installing-solidity.html).
4. Run `npm install` to install project dependencies from `package.json`.

## Dependency Management

NPM dependencies are defined in `package.json`.
This makes it easy for all developers to use the same versions of dependencies,
instead of relying on globally installed dependencies using `npm install -g`.

To add a new dependency, execute `npm install --save-dev [package_name]`. This
adds a new entry to `package.json`. Make sure you commit this change.

## Code Style

### Solidity

We strive to adhere to the [Solidity Style
Guide](http://solidity.readthedocs.io/en/latest/style-guide.html) as much as
possible. The [Solium](https://github.com/duaraghav8/Solium)
linter has been added to check code against this Style Guide. The linter is run
automatically by Continuous Integration.

### Javascript

For plain Javascript files (e.g. tests), the [Javascript Standard
Style](https://standardjs.com/) is used. There are several
[plugins](https://standardjs.com/#are-there-text-editor-plugins) available for
widely-used editors. These also support automatic fixing. This linter is run
automatically by Continuous Integration.

## Credits

Developped by [Frank Bonnet](https://www.linkedin.com/in/frank-bonnet-3b890865/) Software engineer
Documented by [Mark Reuvers](https://www.linkedin.com/in/mark-reuvers/) 