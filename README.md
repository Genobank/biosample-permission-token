![Build Status](https://travis-ci.org/fulldecent/recursive-license-token.svg?branch=master)&nbsp;[![NPM Version](https://badge.fury.io/js/fulldecent%2Frecursive-license-token.svg)](https://www.npmjs.com/package/fulldecent/recursive-license-token)&nbsp;[![Dependencies Status](https://david-dm.org/fulldecent/recursive-license-token.svg)](https://david-dm.org/fulldecent/recursive-license-token)

# Recursive License Token

This is a proof-of-concept demonstration of how to use claims, encoded in non-fungible tokens, to establish a chain of trust for licensing and sublicensing agreements.

## Structure

This smart contract is a thin wrapper on the reference ERC-721 implementation.

- [`recursive-license-token`](src/contracts/tokens/recursive-license-token.sol): This extents the reference nf-token-metadata.sol implementation.

Tests for all new functionality are [here](src/tests). These are specifically made to test different edge cases and behaviours.

## Requirements

* NodeJS 9.0+ is supported
* Windows, Linux or macOS

## Installation

### npm

(NPM INSTALLATION IS NOT SUPPORTED YET)

```
$ npm install fulldecent/recursive-license-token
```

### Source

*This is the recommended installation method if you want to improve the `fulldecent/recursive-license-token` project.*

Clone this repository and install the required `npm` dependencies:

```
$ git clone git@github.com:fulldecent/recursive-license-token.git
$ cd recursive-license-token
$ npm install
```

Make sure that everything has been set up correctly:

```
$ npm run test
```

## Usage

### npm

To interact with this package's contracts within JavaScript code, you simply need to require this package's `.json` files:

```js
const contract = require("fulldecent/recursive-license-token/build/recursive-license-token.json");
console.log(contract);
```

### Remix IDE (Ethereum only)

You can quickly deploy a contract with this library using [Remix IDE](https://remix.ethereum.org). Here is one example.

```solidity
pragma solidity 0.6.2;

import "https://github.com/fulldecent/recursive-license-token/src/contracts/tokens/recursive-license-token.sol";
```

WE ARE ALSO WORKING ON A BLOG POST THAT EXPLAINS THE SIGNIFICANCE HERE AND SHOWS YOU MORE THAT YOU CAN DO AFTER YOU DEPLOY THIS SMART CONTRACT.

## Playground

### Ethereum - Ropsten testnet

WE HAVE NOT DEPLOYED TO ROPSTEN YET

We already deployed some contracts to the [Ropsten](https://ropsten.etherscan.io/) network. You can play with them RIGHT NOW. No need to install the software. In this test version of the contract.

| Contract                                                     | Token address |
| ------------------------------------------------------------ | ------------- |
| [`recursive-license-token`](src/contracts/tokens/recursive-license-token.sol)          | [0x00](https://ropsten.etherscan.io/address/0x00)          |

### Wanchain - testnet

WE HAVE NOT DEPLOYED TO WANCHAIN YET

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to help out.

## Licence

See [LICENSE](./LICENSE) for details.
