// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { IPAssetRegistry } from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import { ISPGNFT } from "@storyprotocol/periphery/interfaces/ISPGNFT.sol";
import { RegistrationWorkflows } from "@storyprotocol/periphery/workflows/RegistrationWorkflows.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/lib/WorkflowStructs.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { PILicenseTemplate } from "@storyprotocol/core/modules/licensing/PILicenseTemplate.sol";
import { PILTerms } from "@storyprotocol/core/interfaces/modules/licensing/IPILicenseTemplate.sol";
import { RoyaltyPolicyLAP } from "@storyprotocol/core/modules/royalty/policies/LAP/RoyaltyPolicyLAP.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { LicenseRegistry } from "@storyprotocol/core/registries/LicenseRegistry.sol";
import { LicensingModule } from "@storyprotocol/core/modules/licensing/LicensingModule.sol";


contract NFTTemplate is ERC721, Ownable {
    uint256 public nextTokenId;
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}
    function mint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId);
        return tokenId;
    }
}

contract SUSD is ERC20 {
    constructor() ERC20("Story USD", "SUSD") {}
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract StoryProtocolManager {
    IPAssetRegistry public immutable IP_ASSET_REGISTRY = IPAssetRegistry(0x28E59E91C0467e89fd0f0438D47Ca839cDfEc095);
    RegistrationWorkflows public immutable REGISTRATION_WORKFLOWS = RegistrationWorkflows(0xde13Be395E1cd753471447Cf6A656979ef87881c);
    NFTTemplate public NFT_TEMPLATE;
    ISPGNFT public SPG_NFT;
    PILicenseTemplate public immutable PIL_TEMPLATE = PILicenseTemplate(0x58E2c909D557Cd23EF90D14f8fd21667A5Ae7a93);
    RoyaltyPolicyLAP public immutable ROYALTY_POLICY_LAP = RoyaltyPolicyLAP(0x28b4F70ffE5ba7A26aEF979226f77Eb57fb9Fdb6);
    SUSD public immutable SUSD_TOKEN = SUSD(0xC0F6E387aC0B324Ec18EAcf22EE7271207dCE3d5);
    LicenseRegistry public immutable LICENSE_REGISTRY = LicenseRegistry(0xBda3992c49E98392e75E78d82B934F3598bA495f);
    LicensingModule public immutable LICENSING_MODULE = LicensingModule(0x5a7D9Fa17DE09350F481A53B470D798c1c1aabae);

    event CollectionCreated(address collectionAddress);
    event NFTRegistered(uint256 indexed chainId, address indexed nftAddress, uint256 tokenId, address ipId);
    event PILTermsRegistered (uint256 licenseTermsId);
    event LicenseAttached(uint256 attachedLicenseTermsId);

    function createCollection(
        string memory collectionName,
        string memory collectionSymbol
    ) public returns (address collectionAddress) {
        SPG_NFT = ISPGNFT(
            REGISTRATION_WORKFLOWS.createCollection(
                ISPGNFT.InitParams({
                    name: collectionName,
                    symbol: collectionSymbol,
                    baseURI: "",
                    contractURI: "",
                    maxSupply: (2**32) - 1,
                    mintFee: 0,
                    mintFeeToken: address(0),
                    mintFeeRecipient: address(this),
                    owner: address(this),
                    mintOpen: true,
                    isPublicMinting: false
                })
            )
        );
        collectionAddress = address(SPG_NFT);
        emit CollectionCreated(collectionAddress);
        return collectionAddress;
    }

    function registerExternalNFT(
        uint256 chainId,
        address nftAddress,
        uint256 tokenId
    ) public returns (address ipId) {
        ipId = IP_ASSET_REGISTRY.register(chainId, nftAddress, tokenId);
        emit NFTRegistered(chainId, nftAddress, tokenId, ipId);
        return ipId;
    }

    function mintAndRegisterIp(
        address collectionAddress,
        address recipient,
        string memory ipMetadataURI,
        string memory ipMetadataJSON,
        string memory nftMetadataURI,
        string memory nftMetadataJSON
    ) public returns (address ipId, uint256 tokenId) {
        bytes32 ipMetadataHash = keccak256(abi.encodePacked(ipMetadataJSON));
        bytes32 nftMetadataHash = keccak256(abi.encodePacked(nftMetadataJSON));
        ISPGNFT collection = ISPGNFT(collectionAddress);
        (ipId, tokenId) = REGISTRATION_WORKFLOWS.mintAndRegisterIp(
            address(collection),
            recipient,
            WorkflowStructs.IPMetadata({
                ipMetadataURI: ipMetadataURI,
                ipMetadataHash: ipMetadataHash,
                nftMetadataURI: nftMetadataURI,
                nftMetadataHash: nftMetadataHash
            })
        );
        emit NFTRegistered(block.chainid, collectionAddress, tokenId, ipId);
    }

    function registerPILTerms() public returns (uint256 licenseTermsId) {
        PILTerms memory pilTerms = PILTerms({
            transferable: true,
            royaltyPolicy: address(ROYALTY_POLICY_LAP),
            defaultMintingFee: 0,
            expiration: 0,
            commercialUse: true,
            commercialAttribution: true,
            commercializerChecker: address(0),
            commercializerCheckerData: "",
            commercialRevShare: 0,
            commercialRevCeiling: 0,
            derivativesAllowed: true,
            derivativesAttribution: true,
            derivativesApproval: true,
            derivativesReciprocal: true,
            derivativeRevCeiling: 0,
            currency: address(SUSD_TOKEN),
            uri: ""
        });
        licenseTermsId = PIL_TEMPLATE.registerLicenseTerms(pilTerms);
        emit PILTermsRegistered(licenseTermsId);
        return licenseTermsId;
    }

    function attachLicenseTerms(address ipId, uint256 licenseTermsId) public {
        LICENSING_MODULE.attachLicenseTerms(ipId, address(PIL_TEMPLATE), licenseTermsId);
        /*(address licenseTemplate, uint256 retrievedLicenseTermsId) = LICENSE_REGISTRY.getAttachedLicenseTerms({
            ipId: ipId,
            index: 0
        });*/
        /*emit LicenseAttached(retrievedLicenseTermsId);*/
        /*return retrievedLicenseTermsId;*/
    }

}
