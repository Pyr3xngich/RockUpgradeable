// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RockPaperScissorsV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address public player1;
    address public player2;
    string public player1Choice;
    string public player2Choice;
    address public winner;
    bool public gameOngoing;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
    __Ownable_init(msg.sender);// Initialize OwnableUpgradeable
    __UUPSUpgradeable_init();   // Initialize UUPSUpgradeable
    gameOngoing = true;         // Start game
}


    function joinGame() public {
        require(gameOngoing, "Game has already ended");
        require(player1 == address(0) || player2 == address(0), "Game is full");

        if (player1 == address(0)) {
            player1 = msg.sender;
        } else {
            player2 = msg.sender;
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
            player1Choice = choice;
        } else {
            player2Choice = choice;
        }

        if (bytes(player1Choice).length > 0 && bytes(player2Choice).length > 0) {
            determineWinner();
        }
    }

    function determineWinner() private {
        require(bytes(player1Choice).length > 0, "Player 1 has not made a choice");
        require(bytes(player2Choice).length > 0, "Player 2 has not made a choice");

        if (keccak256(bytes(player1Choice)) == keccak256(bytes(player2Choice))) {
            winner = address(0); // Draw
        } else if (
            (keccak256(bytes(player1Choice)) == keccak256(bytes("rock")) && keccak256(bytes(player2Choice)) == keccak256(bytes("scissors"))) ||
            (keccak256(bytes(player1Choice)) == keccak256(bytes("scissors")) && keccak256(bytes(player2Choice)) == keccak256(bytes("paper"))) ||
            (keccak256(bytes(player1Choice)) == keccak256(bytes("paper")) && keccak256(bytes(player2Choice)) == keccak256(bytes("rock")))
        ) {
            winner = player1;
        } else {
            winner = player2;
        }

        gameOngoing = false;
    }

    function claimPrize() public {
        require(!gameOngoing, "Game is still ongoing");
        require(msg.sender == winner, "You are not the winner");

        payable(winner).transfer(address(this).balance);
    }

    receive() external payable {}

    // Required for UUPS upgradeability — only owner can authorize upgrades
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}