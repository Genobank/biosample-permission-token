// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IPAssetRegistry } from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import { ISPGNFT } from "@storyprotocol/periphery/interfaces/ISPGNFT.sol";
import { RegistrationWorkflows } from "@storyprotocol/periphery/workflows/RegistrationWorkflows.sol";
/*import { LicenseAttachmentWorkflows } from "@storyprotocol/periphery/workflows/LicenseAttachmentWorkflows.sol";*/
import { ILicenseAttachmentWorkflows } from "@storyprotocol/periphery/interfaces/workflows/ILicenseAttachmentWorkflows.sol";
import { DerivativeWorkflows } from "@storyprotocol/periphery/workflows/DerivativeWorkflows.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/lib/WorkflowStructs.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { PILicenseTemplate } from "@storyprotocol/core/modules/licensing/PILicenseTemplate.sol";
import { PILTerms } from "@storyprotocol/core/interfaces/modules/licensing/IPILicenseTemplate.sol";
import { Licensing } from "@storyprotocol/core/lib/Licensing.sol";
import { RoyaltyPolicyLAP } from "@storyprotocol/core/modules/royalty/policies/LAP/RoyaltyPolicyLAP.sol";
import { PILFlavors } from "@storyprotocol/core/lib/PILFlavors.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { LicenseRegistry } from "@storyprotocol/core/registries/LicenseRegistry.sol";
import { ILicensingModule } from "@storyprotocol/core/interfaces/modules/licensing/ILicensingModule.sol";
import { LicenseToken } from "@storyprotocol/core/LicenseToken.sol";


contract NFTTemplate is ERC721, Ownable {
    uint256 public nextTokenId;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {}

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
    IPAssetRegistry public immutable IP_ASSET_REGISTRY =
        IPAssetRegistry(0x77319B4031e6eF1250907aa00018B8B1c67a244b);

    RegistrationWorkflows public immutable REGISTRATION_WORKFLOWS =
        RegistrationWorkflows(0xbe39E1C756e921BD25DF86e7AAa31106d1eb0424);

    ILicenseAttachmentWorkflows public immutable LICENSE_ATTACHMENT_WORKFLOWS =
        ILicenseAttachmentWorkflows(0xcC2E862bCee5B6036Db0de6E06Ae87e524a79fd8);

    DerivativeWorkflows public immutable DERIVATIVE_WORKFLOWS =
        DerivativeWorkflows(0x9e2d496f72C547C2C535B167e06ED8729B374a4f); 

    NFTTemplate public NFT_TEMPLATE;
    ISPGNFT public SPG_NFT;

    PILicenseTemplate public immutable PIL_TEMPLATE =
        PILicenseTemplate(0x2E896b0b2Fdb7457499B56AAaA4AE55BCB4Cd316);

    SUSD public immutable SUSD_TOKEN =
        SUSD(0xC0F6E387aC0B324Ec18EAcf22EE7271207dCE3d5);

    LicenseRegistry public immutable LICENSE_REGISTRY =
        LicenseRegistry(0x529a750E02d8E2f15649c13D69a465286a780e24);
    
    ILicensingModule internal LICENSING_MODULE =
        ILicensingModule(0x04fbd8a2e56dd85CFD5500A4A4DfA955B9f1dE6f);

    address internal ROYALTY_POLICY_LAP = 0xBe54FB168b3c982b7AaE60dB6CF75Bd8447b390E;

    address internal MERC20 = 0x1514000000000000000000000000000000000000;



    event CollectionCreated(address collectionAddress);
    event NFTRegistered(
        uint256 indexed chainId,
        address indexed nftAddress,
        uint256 tokenId,
        address ipId
    );
    event PILTermsRegistered(uint256 licenseTermsId);
    event LicenseAttached(address licenseTemplate, uint256 attachedLicenseTermsId);
    event AttachedIPandLicense(address ipId, uint256 tokenId, uint256[] licenseTermsIds);
    event mintedLicenseToken(uint256 startLicenseTokenId);
    event mintedComercialLicenseTerms(uint256 licenseId);


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
                    isPublicMinting: true
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
            }),
            true
        );
        emit NFTRegistered(block.chainid, collectionAddress, tokenId, ipId);
        return (ipId, tokenId);
    }

    function mintAndRegisterAndCreateTermsAndAttach(
        address collectionAddress,
        address receiver,
        WorkflowStructs.IPMetadata calldata ipMetadata,
        WorkflowStructs.LicenseTermsData[] calldata licenseTermsData
    ) external returns (address ipId, uint256 tokenId, uint256[] memory licenseTermsIds) {
        (ipId, tokenId, licenseTermsIds) =  LICENSE_ATTACHMENT_WORKFLOWS.mintAndRegisterIpAndAttachPILTerms(
            collectionAddress,
            receiver,
            ipMetadata,
            licenseTermsData,
            true
        );
        emit AttachedIPandLicense(ipId, tokenId, licenseTermsIds);
        return (ipId, tokenId, licenseTermsIds);
    }

    function CreateCommercialRemixLicenseAndAttach(
        address ipId,
        address receiver
    ) public {
        uint256 licenseTermsId = PIL_TEMPLATE.registerLicenseTerms(
            PILFlavors.commercialRemix({
                mintingFee: 0,
                commercialRevShare: 10 * 10 ** 6,
                royaltyPolicy: ROYALTY_POLICY_LAP,
                currencyToken: MERC20
            })
        );

        LICENSING_MODULE.attachLicenseTerms(ipId, address(PIL_TEMPLATE), licenseTermsId);
        uint256 startLicenseTokenId = LICENSING_MODULE.mintLicenseTokens({
            licensorIpId: ipId,
            licenseTemplate: address(PIL_TEMPLATE),
            licenseTermsId: licenseTermsId,
            amount: 2,
            receiver: receiver,
            royaltyContext: "", // for PIL, royaltyContext is empty string
            maxMintingFee: 0,
            maxRevenueShare: 0
        });
    }

    function mintLicenseToken(address ipId, uint256 licenseTermsId, address receiver, uint256 amount) external returns (uint256 startLicenseTokenId)  {
        startLicenseTokenId = LICENSING_MODULE.mintLicenseTokens(
            ipId,
            address(PIL_TEMPLATE),
            licenseTermsId,
            amount,
            receiver,
            "",
            0,
            0
        );
        emit mintedLicenseToken(startLicenseTokenId);
        return startLicenseTokenId;
    }

    function mintDerivativeAndLink(
        uint256[] calldata licenseTokenIds,
        address childCollection,
        WorkflowStructs.IPMetadata calldata meta
    )
        external
        returns (address childIpId, uint256 childTokenId)
    {
        (childIpId, childTokenId) = REGISTRATION_WORKFLOWS.mintAndRegisterIp(
            childCollection,
            msg.sender,
            meta,
            true
        );
        LICENSING_MODULE.registerDerivativeWithLicenseTokens({
            childIpId: childIpId,
            licenseTokenIds: licenseTokenIds,
            royaltyContext:"",
            maxRts: 0
        });
        emit AttachedIPandLicense(childIpId, childTokenId, licenseTokenIds);
        return (childIpId, childTokenId);
    }

    function createCommercialLicenseTerms() public returns (uint256) {

        uint256 commercialLicenseTermsId = PIL_TEMPLATE.registerLicenseTerms(
            PILFlavors.commercialRemix({
                mintingFee: 0,
                commercialRevShare: 10 * 10 ** 6, // 10%
                royaltyPolicy: ROYALTY_POLICY_LAP,
                currencyToken: MERC20
            })
        );

        emit mintedComercialLicenseTerms(commercialLicenseTermsId);
        return commercialLicenseTermsId;
    }

    
}
