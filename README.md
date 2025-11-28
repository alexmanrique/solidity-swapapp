# SwapApp

A Solidity smart contract for token swapping using Uniswap V2 Router on Arbitrum with swap history tracking.

## Smart Contract

The `SwapApp` contract (`src/SwapApp.sol`) provides a simple interface for token swaps with built-in swap history tracking:

### Core Functionality

- **Constructor**: Initializes the contract with a Uniswap V2 Router address
- **swapTokens function**:
  - Accepts tokens from the user
  - Approves the router to spend the tokens
  - Executes a token swap via Uniswap V2 Router's `swapExactTokensForTokens`
  - Automatically records swap information in the user's history
  - Emits a `SwapTokens` event with swap details (user, token addresses, amounts)
  - Uses OpenZeppelin's SafeERC20 for secure token transfers

### Swap History Features

The contract maintains a complete swap history for each user:

- **SwapInfo struct**: Stores comprehensive swap information:

  - `tokenIn`: Address of the input token
  - `tokenOut`: Address of the output token
  - `amountIn`: Amount of tokens swapped in
  - `amountOut`: Amount of tokens received
  - `path`: Complete swap path (array of token addresses)
  - `timestamp`: Block timestamp when the swap occurred
  - `deadline`: Deadline used for the swap

- **getUserSwapHistory(address user)**: Returns the complete swap history array for a user
- **getUserSwapCount(address user)**: Returns the total number of swaps performed by a user
- **getUserSwapAtIndex(address user, uint256 index)**: Returns a specific swap by index (reverts if index is out of bounds)

### Example Usage

```solidity
// Perform a swap
uint256 amountIn = 1000 * 1e6; // 1000 USDT (6 decimals)
uint256 amountOutMin = 900 * 1e18; // Minimum 900 DAI expected
address[] memory path = new address[](2);
path[0] = USDT_ADDRESS;
path[1] = DAI_ADDRESS;
uint256 deadline = block.timestamp + 300; // 5 minutes

swapApp.swapTokens(amountIn, amountOutMin, path, deadline);

// Query swap history
uint256 totalSwaps = swapApp.getUserSwapCount(msg.sender);
SwapApp.SwapInfo[] memory history = swapApp.getUserSwapHistory(msg.sender);
SwapApp.SwapInfo memory firstSwap = swapApp.getUserSwapAtIndex(msg.sender, 0);
```

## Unit Tests

The test suite (`test/SwapApp.t.sol`) includes:

### Basic Functionality Tests

1. **testHasBeenDeployedCorrectly**: Verifies that the contract is deployed with the correct Uniswap V2 Router address

2. **testSwapTokensCorrectly**:
   - Tests a USDT to DAI swap on Arbitrum mainnet (using fork testing)
   - Verifies that the user's USDT balance decreases by the swap amount
   - Verifies that the user's DAI balance increases after the swap
   - Uses a test account with USDT balance on Arbitrum

### Swap History Tests

3. **testSwapHistoryIsRecorded**:

   - Verifies that swaps are automatically recorded in the user's history
   - Checks that swap count increments correctly
   - Validates that all swap information (tokens, amounts, path, timestamp, deadline) is stored accurately

4. **testGetUserSwapAtIndex**:

   - Tests retrieval of a specific swap by index
   - Verifies that the returned swap data matches the original swap

5. **testGetUserSwapAtIndexRevertsOnInvalidIndex**:

   - Ensures the function reverts with a clear error message when accessing an invalid index

6. **testMultipleSwapsAreRecorded**:

   - Verifies that multiple swaps from the same user are all recorded
   - Checks that the history maintains chronological order
   - Validates that swap count correctly reflects multiple swaps

7. **testSwapHistoryIsUserSpecific**:
   - Confirms that swap history is isolated per user
   - Verifies that one user's swaps don't appear in another user's history

### Running Tests with Arbitrum Fork

```shell
$ forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc
```
