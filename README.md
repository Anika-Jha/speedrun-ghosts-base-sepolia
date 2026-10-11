# Speedrun Ghosts

A deterministic one-screen platformer. The browser records one input per tick; the contract replays the input sequence against a fixed level and computes the verified time. Only runs that reach the goal are recorded. Verified inputs are emitted in `RunVerified` for ghost replay, and personal bests update only when strictly faster.

## Level and simulation
- Single source: `level/level.json`, imported by the frontend and deploy helper.
- Integer-only movement: one-dimensional lane with jump height represented as integer ticks.
- Input byte per tick: `0 = run`, `1 = jump`, `2 = no-op`.
- Hazards and goal are deterministic tick positions.
- `MAX_INPUTS = 120`; gas-test this limit before any production use.

## Run frontend
```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```
Set `VITE_SPEEDRUN_CONTRACT` after deployment. No private key is needed in the browser.

## Test/deploy
```bash
forge test
forge build
source .env
forge script script/Deploy.s.sol:Deploy --rpc-url "$BASE_SEPOLIA_RPC_URL" --broadcast
```
Use a local `.env` for deployment secrets; never commit it. Deployment has not been performed by this generated project.

## Gameplay
Click Start, use Space or the Jump button to record a jump input, and finish at the goal. Submit the recorded input log. The contract—not the client—computes the result. Ghost playback uses inputs emitted by verified runs.

## Important limitation
This is a deliberately compact deterministic proof-of-concept rather than a full physics engine. The level definition is shared by the client and deployment tooling; the Solidity contract uses the same documented constants generated from `level/level.json`. Re-run the consistency check whenever level data changes.
