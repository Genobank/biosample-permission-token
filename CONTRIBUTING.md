# Contributing

## Development

The biosample contract should be used and thus deployed for each environment.

Each developer should use his own smart contract for local development. The reason is that each token must have a unique ID and without these data in the database it would be hard to keep track of all the used IDs.

A developer should also use his own Ethereum wallet address and a local database for performing actions. The reaons is that we must keep track of the last nonce used. If something goes wrong, the nonce will be corrupted and it's easier to fix it per environment.

## Deployment

* Anyone can deploy this contract.
* Run `npm run flatten`.
* Copy deployed contract `build/biosample-permission-token.sol` to [Remix IDE](https://remix.ethereum.org).
* Compile and deploy the contract (set name and symbol parameters).
* Use the returned smart contract address.

## Running tests

* Run `npm test`.
* For linter run: `npm run solhint`.

## Coding style

We follow the 0xcert style guide [here](https://github.com/0xcert/solidity-style-guide).

## Requirements

* NodeJS 11/12 is supported.
* MacOS, Linux or Windows.
