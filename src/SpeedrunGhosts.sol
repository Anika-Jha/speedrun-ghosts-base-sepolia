// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SpeedrunGhosts {
    uint256 public constant MAX_INPUTS = 120;
    uint256 public constant GOAL_TICK = 24;
    uint256 public constant JUMP_DURATION = 3;
    uint256 public constant TICKS_PER_SECOND = 10;
    uint8 public constant RUN = 0;
    uint8 public constant JUMP = 1;
    uint8 public constant NOOP = 2;
    uint8[3] private HAZARDS = [7, 15, 20];

    struct Run { address runner; uint32 timeTicks; bytes inputs; }
    uint256 public runCount;
    mapping(uint256 => Run) private runs;
    mapping(address => uint32) public bestTimeTicks;

    event RunVerified(uint256 indexed runId, address indexed runner, uint32 timeTicks, bytes inputs);
    error TooManyInputs();
    error InvalidInput();
    error DidNotReachGoal();
    error HitHazard();

    function submitRun(bytes calldata inputs) external returns (uint256 runId) {
        if (inputs.length > MAX_INPUTS) revert TooManyInputs();
        uint32 ticks = _simulate(inputs);
        if (ticks == 0) revert DidNotReachGoal();
        runId = ++runCount;
        runs[runId] = Run(msg.sender, ticks, inputs);
        uint32 old = bestTimeTicks[msg.sender];
        if (old == 0 || ticks < old) bestTimeTicks[msg.sender] = ticks;
        emit RunVerified(runId, msg.sender, ticks, inputs);
    }

    function getRun(uint256 runId) external view returns (address runner, uint32 timeTicks, bytes memory inputs) {
        Run storage r = runs[runId];
        require(r.runner != address(0), "unknown run");
        return (r.runner, r.timeTicks, r.inputs);
    }

    function simulate(bytes calldata inputs) external pure returns (uint32) { return _simulate(inputs); }

    function _simulate(bytes calldata inputs) internal pure returns (uint32) {
        uint32 jumpLeft = 0;
        for (uint32 i = 0; i < inputs.length; i++) {
            uint8 action = uint8(inputs[i]);
            if (action > NOOP) revert InvalidInput();
            if (action == JUMP && jumpLeft == 0) jumpLeft = uint32(JUMP_DURATION);
            bool jumping = jumpLeft > 0;
            if (jumpLeft > 0) jumpLeft--;
            uint32 tick = i + 1;
            bool hazard = tick == 7 || tick == 15 || tick == 20;
            if (hazard && !jumping) revert HitHazard();
            if (tick >= GOAL_TICK) return tick;
        }
        return 0;
    }
}
