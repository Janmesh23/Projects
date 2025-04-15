// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract GameHub is AccessControl, ReentrancyGuard {
    bytes32 public constant GAME_MASTER = keccak256("GAME_MASTER");
    
    MetaToken public token;
    MetaverseProfile public profile;

    struct Game {
        uint256 entryFee;
        uint256 prizePool;
        bool isActive;
    }
    mapping(uint256 => Game) public games;

    constructor(address _token, address _profile) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        token = MetaToken(_token);
        profile = MetaverseProfile(_profile);
    }

    function joinGame(uint256 gameId) external nonReentrant {
        require(profile.balanceOf(msg.sender) > 0, "No profile");
        Game storage game = games[gameId];
        require(game.isActive, "Game inactive");

        token.transferFrom(msg.sender, address(this), game.entryFee);
        game.prizePool += game.entryFee;
    }

    function resolveGame(uint256 gameId, address winner) 
        external 
        onlyRole(GAME_MASTER)
    {
        Game storage game = games[gameId];
        uint256 prize = (game.prizePool * 80) / 100; // 80% to winner
        uint256 fee = game.prizePool - prize; // 20% platform fee

        token.transfer(winner, prize);
        token.burn(address(this), fee); // Deflationary burn
        game.prizePool = 0;
    }

    // Admin functions
    function createGame(uint256 gameId, uint256 entryFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        games[gameId] = Game(entryFee, 0, true);
    }
}