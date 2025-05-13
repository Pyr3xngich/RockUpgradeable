
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public player1;
    address public player2;
    string public player1Choice;
    string public player2Choice;
    address public winner;
    bool public gameOngoing;

    constructor() {
        gameOngoing = true;  // Initial state of the game
    }

    function joinGame() public {
        require(gameOngoing, "Game has already ended");
        require(player1 == address(0) || player2 == address(0), "Game is full");

        if (player1 == address(0)) {
            player1 = msg.sender;  // First player joins
        } else {
            player2 = msg.sender;  // Second player joins
        }
    }

    function makeChoice(string memory choice) public {
        require(gameOngoing, "Game has already ended");
        require(msg.sender == player1 || msg.sender == player2, "You are not part of the game");
        require(bytes(choice).length > 0, "Choice must not be empty");
        require(
            keccak256(bytes(choice)) == keccak256(bytes("rock")) ||
            keccak256(bytes(choice)) == keccak256(bytes("paper")) ||
            keccak256(bytes(choice)) == keccak256(bytes("scissors")),
            "Invalid choice"
        );

        if (msg.sender == player1) {
            player1Choice = choice;  // Player 1's choice
        } else {
            player2Choice = choice;  // Player 2's choice
        }

        if (bytes(player1Choice).length > 0 && bytes(player2Choice).length > 0) {
            determineWinner();  // If both players have made their choices, determine the winner
        }
    }

    function determineWinner() private {
        require(bytes(player1Choice).length > 0, "Player 1 has not made a choice");
        require(bytes(player2Choice).length > 0, "Player 2 has not made a choice");

        if (keccak256(bytes(player1Choice)) == keccak256(bytes(player2Choice))) {
            winner = address(0);  // It's a draw
        } else if (
            (keccak256(bytes(player1Choice)) == keccak256(bytes("rock")) && keccak256(bytes(player2Choice)) == keccak256(bytes("scissors"))) ||
            (keccak256(bytes(player1Choice)) == keccak256(bytes("scissors")) && keccak256(bytes(player2Choice)) == keccak256(bytes("paper"))) ||
            (keccak256(bytes(player1Choice)) == keccak256(bytes("paper")) && keccak256(bytes(player2Choice)) == keccak256(bytes("rock")))
        ) {
            winner = player1;  // Player 1 wins
        } else {
            winner = player2;  // Player 2 wins
        }

        gameOngoing = false;  // The game ends
    }

    function claimPrize() public {
        require(!gameOngoing, "Game is still ongoing");
        require(msg.sender == winner, "You are not the winner");

        payable(winner).transfer(address(this).balance);  // Transfer the prize to the winner
    }

    // Accept ether directly sent to the contract
    receive() external payable {}
}
