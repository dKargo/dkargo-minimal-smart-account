# dKargo Minimal Smart Account (ERC-7579)

[![Foundry](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge-333333&logo=solidity&logoColor=black)]()
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFBD10.svg)](https://getfoundry.sh/)


**dKargo Minimal Smart Account (MSA)** is an Account Abstraction smart-contract system that implements the ERC-7579 and ERC-4337 standards. This project provides capabilities to create and manage smart accounts on the EVM blockchain.

## Contract Overview
| Contract                                          	| Description                                                                                 	|
|---------------------------------------------------	|---------------------------------------------------------------------------------------------	|
| [MinimalSmartAccount (MSA.sol)](./src/MSA.sol) 	    | A smart account implementation that complies with ERC-7579 and ERC-4337 standards.          	|
| [MSAFactory (MSAFactory.sol)](./src/MSAFactory.sol) 	| Factory contract that creates smart accounts with deterministic addresses.                  	|
| [MSAProxy (MSAProxy.sol)](./src/MSAProxy.sol)       	| Proxy contract for smart accounts that provides upgradeability using the ERC-1967 standard. 	|

## Installation & Setup

### Requirements
- [Foundry](https://getfoundry.sh/) (Forge, Cast, Anvil)
- Node.js and Yarn

### Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/dKargo/dkargo-minimal-smart-account.git
    cd dkargo-minimal-smart-account
    ```

2. Install dependencies:
    ```bash
    forge install
    yarn install
    ```

## Deployment
#### (1) To deploy the contracts, set .env file

```Shell
cp .env.example .env
```

#### (2) Write .env file data
```
ETH_FROM=
MNEMONIC=
SALT=
```

Environment variables used in the deployment script:
- `ETH_FROM`: The address to broadcast transactions from
- `MNEMONIC`: Mnemonic for generating the broadcast address (if ETH_FROM is not specified)
- `SALT`: Salt value for deterministic deployments


#### (3) run the following command:
```bash
yarn deploy

# rpc_endpoints writen in foundry.toml
yarn deploy --network warehouse
```

Or you can directly run the Forge script:

```bash
forge script ./script/Deploy.s.sol --broadcast
```

## Network Environments
RPC endpoints defined in the `foundry.toml` file:
- `local`: http://127.0.0.1:8545
- `warehouse`: https://rpc.warehouse.dkargo.io
- `dkargo`: https://mainnet-rpc.dkargo.io


## License
This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
