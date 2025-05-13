// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RockPaperScissorsV1.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract RockPaperScissorsV1Test is Test {
    RockPaperScissorsV1 game;
    address playerA = vm.addr(1);
    address playerB = vm.addr(2);

    function setUp() public {
        RockPaperScissorsV1 logic = new RockPaperScissorsV1();

        // Deploy proxy and initialize it in one step
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(logic),
            abi.encodeWithSelector(RockPaperScissorsV1.initialize.selector)
        );

        // Correctly cast the proxy address to the game contract
        game = RockPaperScissorsV1(payable(address(proxy)));
    }

    function testPlayersCanJoinGame() public {
        vm.prank(playerA);
        game.joinGame();
        assertEq(game.player1(), playerA);

        vm.prank(playerB);
        game.joinGame();
        assertEq(game.player2(), playerB);
    }

    function testPlayersMakeChoicesAndDetermineWinner() public {
        vm.prank(playerA);
        game.joinGame();
        vm.prank(playerB);
        game.joinGame();

        vm.prank(playerA);
        game.makeChoice("rock");
        assertEq(game.player1Choice(), "rock");

        vm.prank(playerB);
        game.makeChoice("scissors");
        assertEq(game.player2Choice(), "scissors");

        assertEq(game.winner(), playerA);
        assertFalse(game.gameOngoing());
    }

    function testGameEndsInDraw() public {
        vm.prank(playerA);
        game.joinGame();
        vm.prank(playerB);
        game.joinGame();

        vm.prank(playerA);
        game.makeChoice("rock");
        vm.prank(playerB);
        game.makeChoice("rock");

        assertEq(game.winner(), address(0));
        assertFalse(game.gameOngoing());
    }

    function testClaimPrizeByWinner() public {
        vm.deal(address(game), 1 ether);

        vm.prank(playerA);
        game.joinGame();
        vm.prank(playerB);
        game.joinGame();

        vm.prank(playerA);
        game.makeChoice("rock");
        vm.prank(playerB);
        game.makeChoice("scissors");

        uint256 balanceBefore = playerA.balance;

        vm.prank(playerA);
        game.claimPrize();

        assertGt(playerA.balance, balanceBefore);
    }
}
