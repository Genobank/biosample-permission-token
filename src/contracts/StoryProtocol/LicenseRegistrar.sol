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
    function registerLicenseTerms(uint256 royaltyPercentage) external returns (uint256 licenseTermsId) {
        PILTerms memory pilTerms = PILTerms({
            transferable: true,
            royaltyPolicy: address(ROYALTY_POLICY_LAP),
            defaultMintingFee: 0,
            expiration: 0,
            commercialUse: true,
            commercialAttribution: true,
            commercializerChecker: address(0),
            commercializerCheckerData: "",
            commercialRevShare: uint32(royaltyPercentage * 10**6),
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
    }
}
