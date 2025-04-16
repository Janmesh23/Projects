// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MetaToken is ERC20, AccessControl {
    bytes32 public constant GAME_HUB_ROLE = keccak256("GAME_HUB_ROLE");
    uint256 public constant INITIAL_AIRDROP = 100 * 1e18;

    constructor() ERC20("Metaverse Token", "META") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function airdrop(address player) external onlyRole(GAME_HUB_ROLE) {
        _mint(player, INITIAL_AIRDROP);
    }

    function mint(address to, uint256 amount) external onlyRole(GAME_HUB_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(GAME_HUB_ROLE) {
        _burn(from, amount);
    }
}
