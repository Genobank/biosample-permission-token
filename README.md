![Build Status](https://travis-ci.org/fulldecent/biosample-permission-token.svg?branch=master)&nbsp;[![NPM Version](https://badge.fury.io/js/fulldecent%2Fbiosample-permission-token.svg)](https://www.npmjs.com/package/fulldecent/biosample-permission-token)&nbsp;[![Dependencies Status](https://david-dm.org/fulldecent/biosample-permission-token.svg)](https://david-dm.org/fulldecent/biosample-permission-token)

# Biosample Permission Token

This is a proof-of-concept demonstration of how to use claims, encoded in non-fungible tokens, to establish a chain of trust for licensing and sublicensing agreements.

## Structure

This smart contract is a thin wrapper on the reference ERC-721 implementation.

- [`biosample-permission-token`](src/contracts/tokens/biosample-permission-token.sol): This extents the reference nf-token-metadata.sol implementation.

Tests for all new functionality are [here](src/tests). These are specifically made to test different edge cases and behaviours.

## Requirements

* NodeJS 9.0+ is supported
* Windows, Linux or macOS

## Installation

### npm

(NPM INSTALLATION IS NOT SUPPORTED YET)

```
$ npm install fulldecent/biosample-permission-token
```

### Source

*This is the recommended installation method if you want to improve the `fulldecent/biosample-permission-token` project.*

Clone this repository and install the required `npm` dependencies:

```
$ git clone git@github.com:fulldecent/biosample-permission-token.git
$ cd biosample-permission-token
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
const contract = require("fulldecent/biosample-permission-token/build/biosample-permission-token.json");
console.log(contract);
```

### Remix IDE (Ethereum only)

You can quickly deploy a contract with this library using [Remix IDE](https://remix.ethereum.org). Here is one example.

```solidity
pragma solidity 0.6.2;

import "https://github.com/fulldecent/biosample-permission-token/src/contracts/tokens/biosample-permission-token.sol";
```

WE ARE ALSO WORKING ON A BLOG POST THAT EXPLAINS THE SIGNIFICANCE HERE AND SHOWS YOU MORE THAT YOU CAN DO AFTER YOU DEPLOY THIS SMART CONTRACT.

## Playground

### Ethereum - Ropsten testnet

WE HAVE NOT DEPLOYED TO ROPSTEN YET

We already deployed some contracts to the [Ropsten](https://ropsten.etherscan.io/) network. You can play with them RIGHT NOW. No need to install the software. In this test version of the contract.

| Contract                                                     | Token address |
| ------------------------------------------------------------ | ------------- |
| [`biosample-permission-token`](src/contracts/tokens/biosample-permission-token.sol)          | [0x00](https://ropsten.etherscan.io/address/0x00)          |

### Wanchain - testnet

WE HAVE NOT DEPLOYED TO WANCHAIN YET

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to help out.

## Licence

See [LICENSE](./LICENSE) for details.
