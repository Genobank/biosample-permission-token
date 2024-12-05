// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PILicenseTemplate } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/modules/licensing/PILicenseTemplate.sol";
import { PILTerms } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/interfaces/modules/licensing/IPILicenseTemplate.sol";
import { RoyaltyPolicyLAP } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/modules/royalty/policies/LAP/RoyaltyPolicyLAP.sol";
import { SUSD } from "./SUSD.sol"; 

contract LicenseRegistrar {
    PILicenseTemplate public immutable PIL_TEMPLATE = PILicenseTemplate(0x58E2c909D557Cd23EF90D14f8fd21667A5Ae7a93);
    RoyaltyPolicyLAP public immutable ROYALTY_POLICY_LAP = RoyaltyPolicyLAP(0x28b4F70ffE5ba7A26aEF979226f77Eb57fb9Fdb6);
    SUSD public immutable SUSD_TOKEN = SUSD(0xC0F6E387aC0B324Ec18EAcf22EE7271207dCE3d5);

    /// @notice Registers new PIL Terms. Anyone can register PIL Terms.
    /// @param expiration UNIX timestamp of expiration (0 if it does not expire).
    /// @param commercialUse Allows commercial use.
    /// @param commercialAttribution Requires attribution for commercial use.
    /// @param commercialRevShare Percentage as an integer (e.g., 10 = 10%).
    /// @param derivativesAllowed Allows derivatives.
    /// @param derivativesAttribution Requires attribution for derivatives.
    /// @param derivativesApproval Requires approval to use derivatives.
    /// @param derivativesReciprocal Requires reciprocity in derivative licenses.
    /// @param uri URI with additional information about the terms.
    function registerLicenseTerms(
        uint256 expiration,
        bool commercialUse,
        bool commercialAttribution,
        uint32 commercialRevShare,   // Ex: 10 = 10%
        bool derivativesAllowed,
        bool derivativesAttribution,
        bool derivativesApproval,
        bool derivativesReciprocal,
        string memory uri
    ) external returns (uint256 licenseTermsId) {
        uint32 commercialRevSharePPM = commercialRevShare * 10000;
        PILTerms memory pilTerms = PILTerms({
            transferable: true,
            royaltyPolicy: address(ROYALTY_POLICY_LAP),
            defaultMintingFee: 0,
            expiration: expiration,
            commercialUse: commercialUse,
            commercialAttribution: commercialAttribution,
            commercializerChecker: address(0),
            commercializerCheckerData: "",
            commercialRevShare: commercialRevSharePPM,
            commercialRevCeiling: 0,
            derivativesAllowed: derivativesAllowed,
            derivativesAttribution: derivativesAttribution,
            derivativesApproval: derivativesApproval,
            derivativesReciprocal: derivativesReciprocal,
            derivativeRevCeiling: 0,
            currency: address(SUSD_TOKEN),
            uri: uri
        });

        licenseTermsId = PIL_TEMPLATE.registerLicenseTerms(pilTerms);
    }
}
