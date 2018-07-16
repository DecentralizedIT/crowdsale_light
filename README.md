# Generic crowdsale (light) and token repository

### Simple Summary
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

## Simple Summary Token 
 
This is a standard interface for ERC-20 compatible tokens that is very similar to the original standard interface by Vogelsteller and Buterin. The standard allows for the implementation of a standard API for tokens within smart contracts and provides basic functionality to transfer tokens, as well as allow tokens to be approved so they can be spent by another onchain third party. However, the original `approve` function in the ERC-20 token standard is relatively susceptible to attack vectors. This token standard attempts to solve this problem by adding an alternative `approve` function.  
 
 
## Specification 
 
 
### Token 
 
#### totalSupply 
 
This function shows the total supply of tokens. 
 
function totalSupply() external view return (uint) 
 
 
 
#### balanceOf 
 
This function shows the token balance of another account with address `_owner`.  
 
function balanceOf(address _owner) external view returns (uint)  
 
 
 
#### transfer 
 
This function transfers `_value` tokens from the address of the account that signed the transaction to the address of the recipient. Afterwards it shows if the transaction was successful or not. 
 
function transfer(address _to, uint _value) external returns (bool) 
 
 
 
#### transferFrom 
 
This function allows the signer of the transaction to transfer `_value` tokens on behalf of the address `_from` to the address of the recipient (`_to`). This is under the condition that the address `_from` has set aside an allowance for the spender. Afterwards it shows if the transaction was successful or not.  
 
function transferFrom(address _from, address _to, uint _value) external returns (bool) 
 
 
 
#### approve 
 
This function allows `_spender` to withdraw from an account multiple times, up to the `_value’ amount. Afterwards it shows if the approval was successful or not.  
 
Note: this is the original `approve` function. However, this function is relatively susceptible to attack vectors, like the ones described here(https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYK jA_jp-RLM/) and discussed here(https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729) .  This is why this standard interface includes an alternative ‘approve’ function.  
 
function approve(address _spender, uint _value) external returns (bool)  
 
 
#### approve 
 
This function allows `_spender` to withdraw from an account multiple times, up to the `_value’ amount. Afterwards it shows if the approval was successful or not.  
 
Note: this is the alternative `approve` function. This is to prevent a front running attack vector, which is accomplished by adding an expected value to the function. When the function is executed it is required that the `_expected` value matches the actual allowance of `_spender`. 
 
function approve(address _spender, uint _value, uint _expected) external returns (bool);  
 
 
 
#### allowance 
 
This function shows the amount of remaining tokens that `_spender` is still allowed to withdraw from `_owner`. 
 
function allowance(address _owner, address _spender) external view returns (uint) 
 
 
## Simple Summary ManagedToken 
 
This is a standard interface that adds the following functionalities to the basic ERC-20 token: - Locking; - Issuing; - Burning. 
 
 
## Description Note: it is important to recognize that there is a difference between an owner of tokens and the owner(s) of the token contract. The functions described in this interface can only be executed by the owner(s) of the token contract. 
 
With the regular ERC-20 token standard, it is not possible to change certain functions or characteristics after the token has been published However, with this interface the owner of an ERC-20 token contract is able to add additional functionalities that allow them to manage tokens after they have been published.  
 
This interface enables the owner(s) of an ERC-20 token contract to lock tokens, issue additional tokens or burn tokens after the token has been published. Only the addresses in the list of owners can choose to execute these functions and these owners should only be able to execute these functions under certain conditions that are decided upon ahead of time. 
 
This interface can for example be used to let the address of a crowdsale contract manage the token contract. Then, the crowdsale address is the only one that is able to unlock, issue or burn tokens. In this example, it could be decided that the token will remain locked until a crowdsale has been completed successfully. Only when the crowdsale has been completed successfully, can the crowdsale contract unlock the token. It is up to the initiator of the crowdsale contract to decide if the crowdsale contract is owned by one or several parties. 
 
 
## Specification 
 
 
### ManagedToken 
 
#### isLocked 
 
This function shows whether the token is locked or not. 
 
function isLocked() external view returns (bool)  
 
 
 
#### lock 
 
This function locks the token so that the transferring of value is disabled and shows whether the locking was successful or not.  
 
function lock() external returns (bool)  
 
 
 
#### unlock 
 
This function unlocks the token so that the transferring of value is enabled and shows whether the unlocking was successful or not. 
 
function unlock() external returns (bool)  
 
 
 
#### issue 
 
This function issues `_value` new tokens to the destination address and shows if the tokens were successfully issued or not.  
 
function issue(address _to, uint _value) external returns (bool)  
 
 
 
#### burn 
 
This function burns tokens from the address `_from` and shows whether the tokens were successfully burned or not. 
 
function burn(address _from, uint _value) external returns (bool)  
 
 
## Simple Summary Crowdsale 
 
This is a standard interface to manage the crowdsale of an ERC-20 token on the Ethereum blockchain. This interface can be used by any venture (also non-crypto related ventures) to raise funds in a decentralized manner on the Ethereum blockchain. 
 
This crowdsale interface allows the initiator of the crowdsale to make use of two distinct phases: a optional presale phase and a main sale phase. Furthermore, it allows the initiator of the crowdsale to incentivize contributors to contribute early on and to contribute higher volumes during the pre and the main sale while minimizing the risk of early exits. 
 
 
## Description 
 
A presale is a tokensale event that can be used prior to the actual main sale. The ether that is contributed during the presale phase is directly accessible to the initiator of the crowdsale and is often used for marketing and meetups prior to the main sale and to cover the expenses that were incurred in the run-up to the crowdsale. Investors that contribute during the presale often get a higher rate of tokens than the investors that contribute during the main sale. However, the contributions that are made during the presale phase are non-refundable. This means that if the presale does not raise the envisioned amount, investors during the presale phase will not get their contributions back.  
 
The ether that is contributed during the main sale stage is accessible to the initiator after the crowdsale and only when the crowdsale was successful. The investors that contribute during the main sale stage get a lower rate of tokens than the investors that contribute during the presale. However, their contributions are refundable in the case of a failed crowdsale. A crowdsale is considered failed if it does not raise the envisioned minimum amount. In this case, the main sale contributors can execute the `refund` or `refundTo` functions to get back their complete funds (minus the transaction fees).  
 
This standard interface also allows the initiator to incentivize investors to contribute early on during the main sale. It does so by giving the initiator the possibility to assign different conversion rates to different timeframes within the main sale. For example, investors that contribute during the first 24 hours of the main sale could be rewarded with an allocation of 20% bonus tokens. Investors that contribute during the first week could for example be rewarded with an allocation of 10% bonus tokens, while the investors that contribute after the first week are not rewarded with any bonus tokens. This standard interface includes the possibility to temporarily allocate the bonus tokens and to release them at a later date, to prevent early exits with the bonus tokens. 
 
This standard interface also allows the initiator of the crowdsale to incentivize investors to contribute more. It does so by giving the initiator the possibility to assign different volume multipliers to different investment amounts. The initiator can distinguish between different categories of investment amounts. For example, investors that contribute more than 100 ether could be rewarded with an allocation of 20% bonus tokens. Investors that contribute more than 20 ether could be rewarded with an allocation of 10% bonus tokens, while the investors that contribute less than 20 ether are not rewarded with any bonus tokens. This standard interface includes the possibility to temporarily allocate the bonus tokens and to release them at a later date, to prevent early exits with the bonus tokens. 

 ## Specification 
 
### Crowdsale metrics 
 
#### baseRate 
 
This integer shows the conversion rate from ether to tokens without any bonuses. 
 
uint public baseRate  
 
 
 
#### minAmount 
 
This integer shows the minimum amount of ether that has to be received during the crowdsale in order for the crowdsale to be considered successful. If this amount is not raised, the crowdsale is considered to be failed. 
 
Note: the ether that was received during the presale also contributes towards this minimum amount. For example, if the minimum amount of ether is set at 1000 ether and if there has already been 500 ether received during the presale, only 500 ether has to be received during the main sale in order for the crowdsale to be considered successful. 
 
uint public minAmount  
 
 
 
#### maxAmount 
 
This integer shows the maximum amount of ether that can be received during the crowdsale. If this amount is reached, the crowdsale will stop. 
 
uint public maxAmount  
 
 
 
#### minAcceptedAmount 
 
This integer shows the minimum amount that is accepted per individual contribution during the main sale. 
 
uint public minAcceptedAmount  
 
 
 
#### minAmountPresale 
 
This integer shows the minimum amount of ether that has to be received during the presale in order for the presale to be considered successful. If this minimum amount is not received, the crowdsale will not be continued and there will be no main sale.  
 
uint public minAmountPresale  
 
 
 
#### maxAmountPresale 

 This integer shows the maximum amount of ether that can be received during the presale. If this amount is reached, the presale will stop. 
 
 
uint public maxAmountPresale  
 
 
 
#### minAcceptedAmountPresale 
 
This integer shows the minimum amount that is accepted per individual contribution during the presale. 
 
uint public minAcceptedAmountPresale  
 
 
 
#### beneficiary 
 
This is the address of the ‘beneficiary’.  
 
Note: there are different beneficiaries in different contexts.  Often, this refers to the address where the ether that is invested will eventually go to. This the address of the initiator of the crowdsale, not the address of the crowdsale contract.  In other contexts, this most often refers to the address of an individual contributor to the crowdsale. Thus, in these cases the beneficiary is the individual crowdsale investor. 
 
address public beneficiary  
 
 
 
#### start 
 
This integer shows the start date of the crowdsale in a regular calendar date. 
 
 
uint public start  
 
 
 
#### presaleEnd 
 
This integer shows when the presale ends in a regular calendar date.  
 
uint public presaleEnd  
 
 
 
#### crowdsaleEnd 
 
This integer shows when the presale ends in a regular calendar date. 
 
uint public crowdsaleEnd  
 
 
 
#### raised 

 This integer shows the amount of ether that is raised so far during the crowdsale. 
 
uint public raised  
 
 
 
#### allocatedEth 
 
The crowdsale can be set up in such a way that ether can be temporarily allocated/locked up. It can be configured in such a way that the initiator of the crowdsale doesn’t receive all the ether immediately after the crowdsale. For example, ether can be temporarily allocated and be released in four steps with holding periods of three months in between.  
 
This function shows the total amount of ether that is still allocated/locked up. 
 
uint public allocatedEth  
 
 
 
#### allocatedTokens 
 
The crowdsale can also be set up in such a way that not all tokens are issued and distributed immediately during the crowdsale but that a certain amount will be temporarily allocated/locked up.  For example, there could be a certain amount of tokens allocated to the team that has initiated the crowdsale.  Another example would be to temporarily lock up the bonus tokens for the individual investors. Since larger investors might get a significant amount of bonus tokens, they might be incentivized to make an early exit for a small profit. By distributing the bonus tokens at a later date, you can still incentivize large investors to invest while minimizing the risk that these investors will make an early exit.  
 
This integer shows all the tokens that have not directly been issued during the crowdsale and that have currently been allocated/locked up.  
 
uint public allocatedTokens  
 
 
 
### Crowdsale deployment 
 
 
#### stage 
 
The stages are the different steps that the crowdsale goes through and can be seen as the internal states of the crowdsale. This is used by the rest of the code to exclude certain functions at certain stages. There are four different possible stages for the crowdsale.  
 
From the beginning, the crowdsale is in the `Deploying` stage. This means that the configuration of the crowdsale can still be adjusted. When the configuration of the crowdsale is complete (e.g. the whitelist is added, the bonus percentages are configured etc.) the crowdsale goes from the `Deploying` to the `Deployed` stage. Next, the beneficiary has to start the crowdsale. At the same time, the beneficiary has to prove that it is able to sign transactions. This is to prevent that there has been a mistake and 
that the beneficiary actually doesn’t have access to the crowdsale address. When the beneficiary starts the crowdsale and proves that it is able to sign transactions, the crowdsale goes from the `Deployed` stage to the `InProgress` stage. The last stage is when the crowdsale has ended. Here, the crowdsale goes from the `InProgress` stage to the `Ended` stage.  
 
Stages public stage  
 
 
 
#### isInPresalePhase 
 
This function shows if the crowdsale contract is currently in the presale phase or not.  
 
function isInPresalePhase() external view returns (bool) 
 
 
 
 
#### isEnded 
 
This function shows if the crowdsale contract has ended or not. 
 
function isEnded() external view returns (bool) 
 
 
 
#### getReleaseDateCount 
 
This function shows the amount of release dates at which the balances are released to the beneficiary. Here, the beneficiary is the account that the balances are allocated for, which can both be the initiator of the crowdsale or an individual contributor to the crowdsale.  
 
function getReleaseDateCount(address _beneficiary) external view returns (uint) 
 
 
 
#### getReleaseDateAtIndex 
 
This functions shows the date at which a balance is released to the beneficiary, based on the values from `getReleaseDateCount`. This converts the index from `getReleaseDateCount` into a regular calendar date. 
 
function getReleaseDateAtIndex(address _beneficiary, uint64 _index) external view returns (uint64) 
 
 
 
#### getAllocatedBalanceAtReleaseDate 
 
This shows the allocated token and ether balance of the beneficiary at a particular release date. Here, the beneficiary is the account that the balances are allocated for, which can both be the initiator of the crowdsale or an individual contributor to the crowdsale. 
 
function getAllocatedBalanceAtReleaseDate(address _beneficiary, uint64 _releaseDate) external view returns (uint, uint) 
 

 
 
#### getAllocatedBalance 
 
This function shows the total amount of allocated tokens and ether of the beneficiary without taking the different release dates into account. Again, the beneficiary is the account that the balances are allocated for, which can both be the initiator of the crowdsale or an individual contributor to the crowdsale. 
 
function getAllocatedBalance(address _beneficiary) external view returns (uint, uint) 
 
 
 
#### getRefundableBalance 
 
This function shows the refundable ether balance of the beneficiary, where the beneficiary is the individual contributor to the crowdsale. 
 
function getRefundableBalance(address _beneficiary) external view returns (uint) 
 
 
 
#### getCurrentPhase 
 
The result of this function reflects the current phase of the crowdsale. As mentioned in the ‘Description’ above, the initiator is able to configure incentives for investors by assigning different conversion rates to different phases within the crowdsale. 
 
function getCurrentPhase() external view returns (uint) 
 
 
 
#### getRate 
 
This function shows the rate at which ether will be converted into tokens, based on the phase of the crowdsale and the amount of ether that is contributed. If this shows 0, then it is currently not possible to invest.  
 
function getRate(uint _phase, uint _volume) external view returns (uint) 
 
 
 
#### toTokens 
 
This function converts the amount of ether sent by the contributor into tokens using the `_rate` from the `getRate` function. 
 
function toTokens(uint _wei, uint _rate) external view returns (uint) 
 
 
 
#### () 
 
This function receives the ether from the sender (a contributor to the crowdsale) and issues the tokens to the sender in return.  
 
Note: this function requires that the sender is not a contract. This is required because it’s not possible for a contract to specify a gas amount when calling the (internal) send() function. Solidity imposes a maximum amount of gas (2300 gas at the time of writing). Instead, contracts can call the `contribute` function.  
 
function () external payable 
 
 
 
#### contribute 
 
This function receives the ether from the sender and issues the tokens to the sender in return, in case the sender is a contract. Afterwards, it shows the accepted amount of ether. 
 
function contribute() external payable returns (uint) 
 
 
 
#### contributeFor 
 
This function allows someone to invest on behalf of someone else. Here, the ether is received from the sender, but the tokens are issued to a different address (the beneficiary).  This can for example be used by a smart contract that invests on behalf of a group of investors. If 100 investors decide to invest together through the use of a smart contract, this function makes it possible for the tokens to eventually end up at the 100 individual investors.  
 
function contributeFor(address _beneficiary) external payable returns (uint) 
 
 
 
#### withdrawTokens 
 
This function withdraws allocated tokens. When this function is executed by an address that has a balance of allocated tokens with a release date that is in the past (< now) and with a balance that is larger than 0, the tokens are created and the amount is subtracted from the allocated balance for that address. Afterwards, the tokens are sent to the address that has executed the `withdrawTokens` function.   
 
function withdrawTokens() external  
 
 
 
#### withdrawTokensTo 
 
This function allows someone to withdraws allocated tokens on behalf of someone else. Here, the tokens are issued to a different address (the beneficiary) than to the address that executes the ‘withdrawTokensTo` function. This for example enables smart contracts to interact with the crowdsale and invest on behalf of a large group of investors.  
 
 
function withdrawTokensTo(address _beneficiary) external  
 
 
 
#### withdrawEther 
 
This function withdraws ether. When this function is executed by an address that has a balance of allocated ether with a release date that is in the past (< now) and which has a balance that is larger than 0, the ether is subtracted from the allocated balance for that address and sent to the address that has executed the `withdrawEther` function.  
 
function withdrawEther() external 
 
 
 
#### withdrawEtherTo 
 
This function allows someone to withdraw allocated ether on behalf of someone else. Here, the ether is sent to a different address (the beneficiary) than to the address that executes the ‘withdrawEtherTo` function. This for example enables smart contracts to interact with the crowdsale and invest on behalf of a large group of investors.  
 
function withdrawEtherTo(address _beneficiary) external  
 
 
 
#### refund 
 
Investors that have contributed during the main sale and that have a refundable balance can execute this function if the crowdsale was unsuccessful. The crowdsale is considered unsuccessful if  the minimum amount was not raised before the end of the crowdsale.  
 
This function refunds the amount of ether that was contributed (in the case of an unsuccessful crowdsale) and has to be executed by the same address as the address that the contribution was made from. 
 
function refund() external  
 
 
 
#### refundTo 
 
Investors that have contributed during the main sale and that have a refundable balance can execute this function if the crowdsale was unsuccessful. The crowdsale is considered unsuccessful if  the minimum amount was not raised before the end of the crowdsale.  
 
This function enables someone to refund the amount of ether that was contributed (in the case of an unsuccessful crowdsale) and send the refund to a different address. This function still has to be executed by the same address as the address that the contribution was made from. This for example enables smart contracts to interact with the crowdsale and invest on behalf of a large group of investors. 
 
function refundTo(address _beneficiary) external 
  

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

[Frank Bonnet](https://www.linkedin.com/in/frank-bonnet-3b890865/) Software engineer  
[Mark Reuvers](https://www.linkedin.com/in/mark-reuvers/)  