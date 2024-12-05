// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IPAssetRegistry } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/registries/IPAssetRegistry.sol";

contract ExternalNFTRegistrar {
    IPAssetRegistry public immutable IP_ASSET_REGISTRY = IPAssetRegistry(0x28E59E91C0467e89fd0f0438D47Ca839cDfEc095);


    event NFTRegistered(
        uint256 indexed chainId,
        address indexed nftAddress,
        uint256 tokenId,
        address ipId
    );

    function registerExternalNFT(
        uint256 chainId,
        address nftAddress,
        uint256 tokenId
    ) external returns (address ipId) {
        ipId = IP_ASSET_REGISTRY.register(chainId, nftAddress, tokenId);
        emit NFTRegistered(chainId, nftAddress, tokenId, ipId);
    }
}