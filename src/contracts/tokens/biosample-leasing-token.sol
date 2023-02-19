// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC4907/IERC4907.sol";
import "@openzeppelin/contracts/token/ERC4907/ERC4907.sol";

contract BioNFTv2 is ERC4907 {
    struct Sample {
        address owner;
        string metadata;
        uint256 leaseEndTime;
        uint256 expirationTime;
    }

    mapping (uint256 => Sample) private _samples;

    uint256 private _sampleCounter;

    event SampleCreated(address indexed owner, uint256 indexed sampleId, string metadata, uint256 expirationTime);
    event SampleLeased(address indexed lessor, address indexed lessee, uint256 indexed sampleId, uint256 leaseEndTime);
    event SampleRevoked(uint256 indexed sampleId);

    function createSample(string memory metadata, uint256 expirationTime) public returns (uint256) {
        uint256 sampleId = _sampleCounter;
        _samples[sampleId] = Sample(msg.sender, metadata, 0, expirationTime);
        _sampleCounter += 1;

        emit SampleCreated(msg.sender, sampleId, metadata, expirationTime);

        return sampleId;
    }

    function leaseSample(uint256 sampleId, address lessee, uint256 leaseDuration) public {
        require(_samples[sampleId].owner == msg.sender, "BioNFTv2: Only owner can lease sample");
        require(lessee != address(0), "BioNFTv2: Invalid lessee address");

        uint256 leaseEndTime = block.timestamp + leaseDuration;

        _samples[sampleId].leaseEndTime = leaseEndTime;

        _mintFor(lessee, sampleId, leaseEndTime);

        emit SampleLeased(msg.sender, lessee, sampleId, leaseEndTime);
    }

    function revokeSample(uint256 sampleId) public {
        require(_samples[sampleId].owner == msg.sender, "BioNFTv2: Only owner can revoke sample");

        _samples[sampleId].expirationTime = block.timestamp;

        emit SampleRevoked(sampleId);
    }

    function isSampleExpired(uint256 sampleId) public view returns (bool) {
        return (_samples[sampleId].expirationTime != 0 && block.timestamp >= _samples[sampleId].expirationTime);
    }

    function getSampleMetadata(uint256 sampleId) public view returns (string memory) {
        return _samples[sampleId].metadata;
    }

    function getSampleOwner(uint256 sampleId) public view returns (address) {
        return _samples[sampleId].owner;
    }
}
