//License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC4907/ERC4907.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BioNFTv2 is ERC4907, ReentrancyGuard {
    // Variables
    uint256 public nextTokenId;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private _expirationDates;
    mapping(uint256 => bool) private _consents;
    mapping(uint256 => mapping(address => bool)) private _accessPermissions;
    mapping(uint256 => mapping(address => bool)) private _computePermissions;
    mapping(uint256 => bool) private _biodataErased;
    mapping(uint256 => uint256) private _lastRewardDate;
    uint256 public constant TOKENS_PER_DAY = 1;
    uint256 public constant SECONDS_PER_DAY = 86400;

    // Events
    event TokenMinted(uint256 tokenId, string tokenURI, uint256 expirationDate);
    event ConsentGiven(uint256 tokenId);
    event ConsentRevoked(uint256 tokenId);
    event AccessPermissionGranted(uint256 tokenId, address grantedAddress);
    event AccessPermissionRevoked(uint256 tokenId, address revokedAddress);
    event ComputePermissionGranted(uint256 tokenId, address grantedAddress);
    event ComputePermissionRevoked(uint256 tokenId, address revokedAddress);
    event BiodataErased(uint256 tokenId);
    event RewardClaimed(uint256 tokenId, address recipient, uint256 amount);

    // Constructor
    constructor() ERC4907("BioNFTv2", "BNFT2") {}

    // Mint a new token
    function mint(string memory tokenURI, uint256 expirationDate, string memory biosampleID, uint256 leasingPeriod) public returns (uint256) {
        require(leasingPeriod > 0, "BioNFTv2: leasing period can't be zero");
        uint256 newTokenId = nextTokenId;
        nextTokenId += 1;
        _mint(msg.sender, newTokenId, 1, "");
        _setTokenURI(newTokenId, tokenURI);
        _expirationDates[newTokenId] = expirationDate;
        _consents[newTokenId] = false;
        _setBiosampleID(newTokenId, biosampleID);
        _biodataErased[newTokenId] = false;
        _lastRewardDate[newTokenId] = block.timestamp;
        _startLease(newTokenId, leasingPeriod);
        emit TokenMinted(newTokenId, tokenURI, expirationDate);
        return newTokenId;
    }

    // Set the token URI
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal virtual {
        _tokenURIs[tokenId] = tokenURI;
    }

    // Get the token URI
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "BioNFTv2: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    // Set the Biosample ID
    function _setBiosampleID(uint256 tokenId, string memory biosampleID) internal virtual {
        require(_exists(tokenId), "BioNFTv2: set Biosample ID of nonexistent token");
        require(bytes(biosampleID).length > 0, "BioNFTv2: Biosample ID can't be empty");
_tokenURIs[tokenId] = biosampleID;
}
// Get the Biosample ID
function biosampleID(uint256 tokenId) public view virtual returns (string memory) {
    require(_exists(tokenId), "BioNFTv2: Biosample ID query for nonexistent token");
    return _tokenURIs[tokenId];
}

// Set consent to process data
function giveConsent(uint256 tokenId) public {
    require(_exists(tokenId), "BioNFTv2: give consent for nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: consent can be given only by the owner");
    require(!_consents[tokenId], "BioNFTv2: consent has already been given");
    _consents[tokenId] = true;
    emit ConsentGiven(tokenId);
}

// Revoke consent to process data
function revokeConsent(uint256 tokenId) public {
    require(_exists(tokenId), "BioNFTv2: revoke consent for nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: consent can be revoked only by the owner");
    require(_consents[tokenId], "BioNFTv2: consent has not been given yet");
    _consents[tokenId] = false;
    emit ConsentRevoked(tokenId);
}

// Grant access permission
function grantAccessPermission(uint256 tokenId, address grantedAddress) public {
    require(_exists(tokenId), "BioNFTv2: grant access permission for nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: access permission can be granted only by the owner");
    _accessPermissions[tokenId][grantedAddress] = true;
    emit AccessPermissionGranted(tokenId, grantedAddress);
}

// Revoke access permission
function revokeAccessPermission(uint256 tokenId, address revokedAddress) public {
    require(_exists(tokenId), "BioNFTv2: revoke access permission for nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: access permission can be revoked only by the owner");
    _accessPermissions[tokenId][revokedAddress] = false;
    emit AccessPermissionRevoked(tokenId, revokedAddress);
}

// Grant compute permission
function grantComputePermission(uint256 tokenId, address grantedAddress) public {
    require(_exists(tokenId), "BioNFTv2: grant compute permission for nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: compute permission can be granted only by the owner");
    _computePermissions[tokenId][grantedAddress] = true;
    emit ComputePermissionGranted(tokenId, grantedAddress);
}

// Revoke compute permission
function revokeComputePermission(uint256 tokenId, address revokedAddress) public {
    require(_exists(tokenId), "BioNFTv2: revoke compute permission for nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: compute permission can be revoked only by the owner");
    _computePermissions[tokenId][revokedAddress] = false;
    emit ComputePermissionRevoked(tokenId, revokedAddress);
}

// Erase the biodata
function eraseBiodata(uint256 tokenId) public {
    require(_exists(tokenId), "BioNFTv2: erase biodata of nonexistent token");
    require(msg.sender == ownerOf(tokenId), "BioNFTv2: erase biodata can be done only by the owner");
    require(!_biodataErased[tokenId], "BioNFTv2: biodata has already been erased");
_biodataErased[tokenId] = true;
emit BiodataErased(tokenId);
}
// Check if access is permitted
function accessPermitted(uint256 tokenId, address requester) public view returns (bool) {
    return _exists(tokenId) && _consents[tokenId] && _accessPermissions[tokenId][requester];
}

// Check if compute is permitted
function computePermitted(uint256 tokenId, address requester) public view returns (bool) {
    return _exists(tokenId) && _consents[tokenId] && _computePermissions[tokenId][requester];
}

// Check if consent has been given
function hasConsent(uint256 tokenId) public view returns (bool) {
    return _exists(tokenId) && _consents[tokenId];
}

// Get the expiration date
function expirationDate(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BioNFTv2: expiration date query for nonexistent token");
    return _expirationDates[tokenId];
}

// Claim reward for leasing the token
function claimReward(uint256 tokenId) public nonReentrant {
    require(_exists(tokenId), "BioNFTv2: claim reward for nonexistent token");
    require(ownerOf(tokenId) == msg.sender, "BioNFTv2: claim reward can be done only by the owner");
    require(!_biodataErased[tokenId], "BioNFTv2: claim reward is not possible when biodata is erased");
    require(block.timestamp > _lastRewardDate[tokenId], "BioNFTv2: reward can be claimed only once per day");
    uint256 daysElapsed = (block.timestamp - _lastRewardDate[tokenId]) / SECONDS_PER_DAY;
    uint256 rewardAmount = daysElapsed * TOKENS_PER_DAY;
    ERC20 token = new ERC20("Token", "TKN");
    token.mint(msg.sender, rewardAmount);
    _lastRewardDate[tokenId] = _lastRewardDate[tokenId] + (daysElapsed * SECONDS_PER_DAY);
    emit RewardClaimed(tokenId, msg.sender, rewardAmount);
}

// Override transfer functions to prevent transfer of tokens
function transferFrom(address, address, uint256) public virtual override {
    revert("BioNFTv2: transfers are not allowed");
}

function safeTransferFrom(address, address, uint256) public virtual override {
    revert("BioNFTv2: transfers are not allowed");
}

function safeTransferFrom(address, address, uint256, bytes memory) public virtual override {
    revert("BioNFTv2: transfers are not allowed");
}

// Override approval functions to prevent approval of tokens
function approve(address, uint256) public virtual override {
    revert("BioNFTv2: approvals are not allowed");
}

function setApprovalForAll(address, bool) public virtual override {
    revert("BioNFTv2: approvals are not allowed");
}
}


