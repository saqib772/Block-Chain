### Your NFT Token

This is an ERC-20 compliant token contract for "Your NFT" with the symbol "Yours" and a total supply of 1 million tokens. The contract is written in Solidity and follows the OpenZeppelin library for security and best practices.

## Deployment

To deploy this contract, follow these steps:

Copy the contract code to a file named YourNFT.sol
* Compile the contract using a Solidity compiler of your choice (version 0.8.0 or higher)
* Deploy the compiled contract to the Ethereum network of your choice using a tool like Remix or Truffle

Usage
Once deployed, the following functions can be used:

```balanceOf(address account) -> uint256```
Returns the balance of tokens for the specified account.

```allowance(address owner, address spender) -> uint256```
Returns the amount of tokens that spender is allowed to spend on behalf of owner.

``` transfer(address to, uint256 value) -> bool```
Transfers value amount of tokens from the caller's account to to.

``` approve(address spender, uint256 value) -> bool ```
Allows spender to spend value tokens on behalf of the caller.

```transferFrom(address from, address to, uint256 value) -> bool```
Transfers value amount of tokens from from to to, after the approval of from.

# License
This code is licensed under the MIT license. See the LICENSE file for more details.

# Acknowledgements
This contract is based on the ERC-20 standard and uses the OpenZeppelin library for security and best practices.

