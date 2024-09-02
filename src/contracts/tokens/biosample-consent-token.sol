// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BiosampleConsentToken is ERC721, Ownable {
    using Counters for Counters.Counter;

    IERC20 public rewardToken;
    Counters.Counter private _tokenIds;
    string public namespace;

    struct Consent {
        uint256 studyId;
        uint256 startTime;
        uint256 duration;
        uint256 rewardAmount;
        address locker;
        bool isLocked;
        bool rewardClaimed;
    }

 function giveConsent(uint256 studyId, uint256 duration, uint256 rewardAmount) external {
        require(!studyParticipants[studyId][msg.sender], "Already participating in this study");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);

        consents[newTokenId] = Consent({
            studyId: studyId,
            startTime: block.timestamp,
            duration: duration,
            rewardAmount: rewardAmount,
            locker: address(0),
            isLocked: false,
            rewardClaimed: false
        });

        studyParticipants[studyId][msg.sender] = true;
        emit ConsentGiven(newTokenId, studyId, duration);
    }

    function revokeConsent(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(!consents[tokenId].isLocked, "Token is locked");

        uint256 studyId = consents[tokenId].studyId;
        studyParticipants[studyId][msg.sender] = false;
        
        _burn(tokenId);
        delete consents[tokenId];

        emit ConsentRevoked(tokenId, studyId);
    }

    function lock(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(!consents[tokenId].isLocked, "Token is already locked");

        consents[tokenId].isLocked = true;
        consents[tokenId].locker = msg.sender;

        emit TokenLocked(tokenId, msg.sender);
    }
 function unlock(uint256 tokenId) external {
        require(consents[tokenId].locker == msg.sender, "Not the locker");
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

        require(rewardToken.transfer(msg.sender, rewardAmount), "Reward transfer failed");

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

    function setTokenUri(uint256 _tokenId, string calldata _permission) external {
        require(address(uint160(_tokenId)) == msg.sender, "TokenIds are namespaced to permitters");
        _setTokenUri(_tokenId, _permission);
        emit URI(_permission, _tokenId);
    }

    function createWithSignature(
        uint256 _tokenId,
        string memory _permission,
        uint256 _seed,
        bytes32 _signatureR,
        bytes32 _signatureS,
        uint8 _signatureV,
        SignatureKind _signatureKind
    ) public {
        bytes32 _claim = getCreateClaim(_tokenId, _seed);
        require(
            isValidSignature(
                address(uint160(_tokenId)),
                _claim,
                _signatureR,
                _signatureS,
                _signatureV,
                _signatureKind
            ),
            "Signature is not valid."
        );
        require(!usedClaims[_claim], "Claim already used.");
        usedClaims[_claim] = true;
        _safeMint(address(uint160(_tokenId)), _tokenId);
        _setTokenUri(_tokenId, _permission);
        emit URI(_permission, _tokenId);
    }

    function setTokenUriWithSignature(
        uint256 _tokenId,
        string calldata _permission,
        uint256 _seed,
        bytes32 _signatureR,
        bytes32 _signatureS,
        uint8 _signatureV,
        SignatureKind _signatureKind
    ) external {
        bytes32 _claim = getUpdateUriClaim(_tokenId, _permission, _seed);
        require(
            isValidSignature(
                address(uint160(_tokenId)),
                _claim,
                _signatureR,
                _signatureS,
                _signatureV,
                _signatureKind
            ),
            "Signature is not valid."
        );
        require(!usedClaims[_claim], "Claim already used.");
        usedClaims[_claim] = true;
        _setTokenUri(_tokenId, _permission);
        emit URI(_permission, _tokenId);
    }

    function isValidSignature(
        address _signer,
        bytes32 _claim,
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        SignatureKind _kind
    ) public pure returns (bool) {
        if (_kind == SignatureKind.no_prefix) {
            return _signer == ecrecover(_claim, _v, _r, _s);
        } else if (_kind == SignatureKind.eth_sign) {
            return _signer == ecrecover(
                keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _claim)),
                _v,
                _r,
                _s
            );
        } else {
            revert("Invalid signature kind.");
        }
    }

    function getCreateClaim(uint256 _tokenId, uint256 _seed) public view returns (bytes32) {
        return keccak256(abi.encodePacked(namespace, ".create", _tokenId, _seed));
    }

    function getUpdateUriClaim(uint256 _tokenId, string memory _permission, uint256 _seed) public view returns (bytes32) {
        return keccak256(abi.encodePacked(namespace, ".permit", _tokenId, _permission, _seed));
    }
 function _setTokenUri(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
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

    function withdrawUnclaimedRewards() external onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        require(rewardToken.transfer(owner(), balance), "Withdrawal failed");
    }
}

