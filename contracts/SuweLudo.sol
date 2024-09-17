// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

contract SuweLudo {

    uint public minimumDiceValue;
    uint public maximumDiceValue;
    uint public maximumPlayers;
    uint public facesOfDice;

    
    mapping(string => bool) public registeredPlayers;

    
    mapping(string => uint[]) public scoreBoard;

    string[] public playerNames;

    modifier onlyRegistered(string memory name) {
        require(registeredPlayers[name], "You must register first");
        _;
    }

    constructor(
        uint _maximumPlayers, 
        uint _facesOfDice, 
        string[] memory names
    ) {
        require(_maximumPlayers > 0 && _maximumPlayers <= 4, "Player count must be between 1 and 4");
        require(_facesOfDice >= 6, "Minimum dice faces must be 6");

        maximumPlayers = _maximumPlayers;
        facesOfDice = _facesOfDice;
        minimumDiceValue = 1;
        maximumDiceValue = _facesOfDice;

        for (uint i = 0; i < _maximumPlayers; i++) {
            registeredPlayers[names[i]] = true;
            playerNames.push(names[i]);
        }
    }

    
    function playLudo(string memory name) external onlyRegistered(name) {
        uint diceRoll = randomDiceRoll();
        scoreBoard[name].push(diceRoll);
    }

    
    function getPlayerScores(string memory name) public view onlyRegistered(name) returns (uint[] memory) {
        return scoreBoard[name];
    }

    function calculateTotalScore(string memory name) public view onlyRegistered(name) returns (uint) {
        uint[] memory scores = scoreBoard[name];
        uint totalScore = 0;
        for (uint i = 0; i < scores.length; i++) {
            totalScore += scores[i];
        }
        return totalScore;
    }

    
    function determineWinner() public view returns (string memory) {
        string memory winner = playerNames[0];
        uint highestScore = calculateTotalScore(winner);

        for (uint i = 1; i < playerNames.length; i++) {
            string memory playerName = playerNames[i];
            uint totalScore = calculateTotalScore(playerName);

            if (totalScore > highestScore) {
                highestScore = totalScore;
                winner = playerName;
            }
        }

        return winner;
    }

    function randomDiceRoll() private view returns (uint) {
        return (uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), msg.sender))) % facesOfDice) + minimumDiceValue;
    }

    function getLeaderboard() public view returns (string[] memory, uint[] memory) {
        string;
        uint;
        
        for (uint i = 0; i < playerNames.length; i++) {
            string memory playerName = playerNames[i];
            uint playerScore = calculateTotalScore(playerName);

            for (uint j = 0; j < 3; j++) {
                if (playerScore > topScores[j]) {
                    // Shift lower scores down the leaderboard
                    for (uint k = 2; k > j; k--) {
                        topScores[k] = topScores[k - 1];
                        topPlayers[k] = topPlayers[k - 1];
                    }
                    topScores[j] = playerScore;
                    topPlayers[j] = playerName;
                    break;
                }
            }
        }

        return (topPlayers, topScores);
    }

    
    function resetGame() public {
        for (uint i = 0; i < playerNames.length; i++) {
            delete scoreBoard[playerNames[i]];
        }
    }
}
