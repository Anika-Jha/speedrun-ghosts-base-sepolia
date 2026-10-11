// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/SpeedrunGhosts.sol";
contract SpeedrunGhostsTest is Test {
    SpeedrunGhosts game; address alice = address(0xA11CE); address bob = address(0xB0B);
    function setUp() public { game = new SpeedrunGhosts(); }
    function _winningInputs() internal pure returns (bytes memory b) {
        b = new bytes(24);
        for (uint256 i; i < 24; i++) b[i] = bytes1(uint8(i == 6 || i == 14 || i == 19 ? 1 : 0));
    }
    function testValidRunStoredAndBestSet() public {
        vm.prank(alice); uint256 id = game.submitRun(_winningInputs());
        (address runner,uint32 ticks,bytes memory inputs) = game.getRun(id);
        assertEq(runner, alice); assertEq(ticks, 24); assertEq(inputs.length, 24); assertEq(game.bestTimeTicks(alice), 24);
    }
    function testIncompleteRunRejected() public {
        vm.prank(alice); vm.expectRevert(SpeedrunGhosts.DidNotReachGoal.selector); game.submitRun(hex"000000");
    }
    function testInvalidInputRejected() public {
        bytes memory b = _winningInputs(); b[0] = bytes1(uint8(9));
        vm.prank(alice); vm.expectRevert(SpeedrunGhosts.InvalidInput.selector); game.submitRun(b);
    }
    function testInputLengthBound() public {
        bytes memory b = new bytes(121);
        vm.prank(alice); vm.expectRevert(SpeedrunGhosts.TooManyInputs.selector); game.submitRun(b);
    }
    function testPersonalBestOnlyImproves() public {
        vm.prank(alice); game.submitRun(_winningInputs());
        bytes memory faster = new bytes(24);
        for(uint256 i; i<24; i++) faster[i] = bytes1(uint8(i==6||i==14||i==19 ? 1 : 0));
        vm.prank(alice); game.submitRun(faster);
        assertEq(game.bestTimeTicks(alice), 24);
    }
    function testGhostInputsAreRetrievable() public {
        vm.prank(alice); uint256 id = game.submitRun(_winningInputs());
        (,,bytes memory inputs) = game.getRun(id); assertEq(keccak256(inputs), keccak256(_winningInputs()));
    }
}
