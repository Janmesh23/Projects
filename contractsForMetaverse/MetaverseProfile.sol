// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MetaverseProfile is ERC721, AccessControl {
    bytes32 public constant PROFILE_MINTER = keccak256("PROFILE_MINTER");
    uint256 private _tokenIdCounter;
    
    struct Profile {
        string username;
        uint256 joinDate;
    }
    mapping(uint256 => Profile) public profiles;
    mapping(address => uint256) public addressToTokenId;

    constructor() ERC721("MetaverseProfile", "MVP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mintProfile(address player, string memory username) 
        external 
        onlyRole(PROFILE_MINTER) 
    {
        require(balanceOf(player) == 0, "Already has profile");
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(player, tokenId);
        profiles[tokenId] = Profile(username, block.timestamp);
        addressToTokenId[player] = tokenId;
    }

    // Soulbound: Override transfers
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        require(auth == address(0), "Cannot transfer");
        return super._update(to, tokenId, auth);
    }

    // Support Interface
    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}