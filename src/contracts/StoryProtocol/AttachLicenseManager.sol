// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "https://raw.githubusercontent.com/storyprotocol/protocol-core-v1/main/contracts/modules/licensing/LicensingModule.sol";
import "https://raw.githubusercontent.com/storyprotocol/protocol-core-v1/main/contracts/modules/licensing/PILicenseTemplate.sol";

contract AttachLicenseManager {
    LicensingModule public constant LICENSING_MODULE = LicensingModule(0x5a7D9Fa17DE09350F481A53B470D798c1c1aabae);
    PILicenseTemplate public constant PIL_TEMPLATE = PILicenseTemplate(0x58E2c909D557Cd23EF90D14f8fd21667A5Ae7a93);

    event LicenseTermsAttached(
        address indexed ipId,
        address licenseTemplate,
        uint256 licenseTermsId,
        address indexed attachedBy
    );

    function attachLicenseTerms(address ipId, uint256 licenseTermsId) external {
        LICENSING_MODULE.attachLicenseTerms(ipId, address(PIL_TEMPLATE), licenseTermsId);
        emit LicenseTermsAttached(ipId, address(PIL_TEMPLATE), licenseTermsId, msg.sender);
    }
}
