// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BiosampleConsentToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20; 

    IERC20 public rewardToken;
    Counters.Counter private _tokenIds;
    string public namespace;

    address public executorWallet;

    struct Consent {
        uint256 studyId;
        uint256 tokenId;
        uint256 startTime;
        uint256 duration;
        uint256 rewardAmount;
        address originalOwner;
        address locker;
        bool isLocked;
        bool rewardClaimed;
    }

    mapping(uint256 => Consent) public consents;
    mapping(uint256 => mapping(address => bool)) public studyParticipants;
    mapping(uint256 => string) private _tokenURIs;
    mapping(bytes32 => bool) private usedClaims;
    mapping(uint256 => uint256) public burnSchedule;

    event ConsentGiven(uint256 tokenId, uint256 studyId, uint256 duration);
    event ConsentRevoked(uint256 tokenId, uint256 studyId);
    event TokenLocked(uint256 tokenId, address locker);
    event TokenUnlocked(uint256 tokenId);
    event RewardClaimed(uint256 tokenId, uint256 studyId, uint256 rewardAmount);
    event TokenScheduledForBurn(uint256 tokenId, uint256 burnTime);
    event URI(string value, uint256 indexed id);

    constructor(address rewardTokenAddress) ERC721("Biosample Consent Token", "BCT") {
        executorWallet = msg.sender;
        rewardToken = IERC20(rewardTokenAddress);
    }

    modifier onlyOwnerOrExecutor(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender || executorWallet == msg.sender, "Not authorized");
        _;
    }

    function giveConsent(
        uint256 studyId, 
        uint256 duration, 
        uint256 rewardAmount, 
        address from,
        address _to
    ) external returns (Consent memory) {
        if (msg.sender != executorWallet) {
            from = msg.sender;
        }
        require(!studyParticipants[studyId][_to], "Already participating in this study");
        
        // Si la duración es 0, se asigna 1 año (en segundos)
        if (duration == 0) {
            duration = 365 * 24 * 60 * 60; // 1 año en segundos
        }

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(from, newTokenId);
        _transfer(from, _to, newTokenId);

        // Crear y almacenar la metadata del consentimiento
        Consent memory newConsent = Consent({
            studyId: studyId,
            tokenId: newTokenId,
            startTime: block.timestamp,
            duration: duration,
            rewardAmount: rewardAmount,
            originalOwner: from,
            locker: _to,
            isLocked: true,
            rewardClaimed: false
        });

        consents[newTokenId] = newConsent;
        studyParticipants[studyId][_to] = true;
        uint256 burnTime = block.timestamp + duration;
        burnSchedule[newTokenId] = burnTime;

        emit ConsentGiven(newTokenId, studyId, duration);
        emit TokenLocked(newTokenId, _to);

        // Retornar la metadata creada
        return newConsent;
    }



    function revokeConsent(uint256 tokenId, address owner) external {
        if (msg.sender != executorWallet) {
            owner = msg.sender;
        }
        require(ownerOf(tokenId) == owner, "Not the token owner");
        Consent memory consent = consents[tokenId];
        require(consent.isLocked, "Token is not locked");
        unlock(tokenId);
        _burn(tokenId);
        delete studyParticipants[consent.studyId][owner];
        delete burnSchedule[tokenId];
        delete consents[tokenId];
        emit ConsentRevoked(tokenId, consent.studyId);
    }



    function _transfer(address from, address to, uint256 tokenId) internal override {
        require(!consents[tokenId].isLocked, "Token is rented and cannot be transferred");
        super._transfer(from, to, tokenId);
    }

    function lock(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender || msg.sender == executorWallet, "Not authorized to lock");
        require(!consents[tokenId].isLocked, "Token is already locked");
        consents[tokenId].isLocked = true;
        consents[tokenId].locker = msg.sender;
        emit TokenLocked(tokenId, msg.sender);
    }


    function unlock(uint256 tokenId) public {
        require(consents[tokenId].locker == msg.sender || msg.sender == executorWallet, "Not the locker");
        require(consents[tokenId].isLocked, "Token is not locked");
        consents[tokenId].isLocked = false;
        consents[tokenId].locker = address(0);
        emit TokenUnlocked(tokenId);
    }


    function claimReward(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(!consents[tokenId].rewardClaimed, "Reward already claimed");
        require(block.timestamp >= consents[tokenId].startTime + consents[tokenId].duration, "Study duration not completed");
        consents[tokenId].rewardClaimed = true;
        uint256 rewardAmount = consents[tokenId].rewardAmount;
        rewardToken.safeTransfer(msg.sender, rewardAmount);  // Uso correcto de safeTransfer
        emit RewardClaimed(tokenId, consents[tokenId].studyId, rewardAmount);
    }

    function transferAndLock(uint256 tokenId, address to) external {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(!consents[tokenId].isLocked, "Token is already locked");
        _transfer(msg.sender, to, tokenId);
        consents[tokenId].isLocked = true;
        consents[tokenId].locker = to;
        emit TokenLocked(tokenId, to);
    }

    function mint(uint256 _tokenId, address _receiverId, string calldata _permission) external {
        require(address(uint160(_tokenId)) == msg.sender, "TokenIds are namespaced to permitters");
        _safeMint(msg.sender, _tokenId);
        _setTokenUri(_tokenId, _permission);
        emit URI(_permission, _tokenId);
        if (msg.sender != _receiverId) {
            _transfer(msg.sender, _receiverId, _tokenId);
        }
    }

    function extendConsentDuration(uint256 tokenId, uint256 additionalDuration) external {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner");
        consents[tokenId].duration += additionalDuration;
    }

    function getConsentDetails(uint256 tokenId) external view returns (Consent memory) {
        return consents[tokenId];
    }

    function isParticipatingInStudy(uint256 studyId, address participant) external view returns (bool) {
        return studyParticipants[studyId][participant];
    }

    function setRewardToken(address newRewardToken) external onlyOwner {
        rewardToken = IERC20(newRewardToken);
    }

    function _setTokenUri(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function withdrawUnclaimedRewards() external onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        require(rewardToken.transfer(owner(), balance), "Withdrawal failed");
    }
}

