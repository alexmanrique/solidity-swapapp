# SwapApp

A Solidity smart contract for token swapping using Uniswap V2 Router on Arbitrum.

## Smart Contract

The `SwapApp` contract (`src/SwapApp.sol`) provides a simple interface for token swaps:

- **Constructor**: Initializes the contract with a Uniswap V2 Router address
- **swapTokens function**:
  - Accepts tokens from the user
  - Approves the router to spend the tokens
  - Executes a token swap via Uniswap V2 Router's `swapExactTokensForTokens`
  - Emits a `SwapTokens` event with swap details (token addresses, amounts)
  - Uses OpenZeppelin's SafeERC20 for secure token transfers

## Unit Tests

The test suite (`test/SwapApp.t.sol`) includes:

1. **testHasBeenDeployedCorrectly**: Verifies that the contract is deployed with the correct Uniswap V2 Router address
2. **testSwapTokensCorrectly**:
   - Tests a USDT to DAI swap on Arbitrum mainnet (using fork testing)
   - Verifies that the user's USDT balance decreases by the swap amount
   - Verifies that the user's DAI balance increases after the swap
   - Uses a test account with USDT balance on Arbitrum

### Running Tests with Arbitrum Fork

```shell
$ forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
