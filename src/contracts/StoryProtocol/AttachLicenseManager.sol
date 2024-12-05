// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { LicensingModule } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/modules/licensing/LicensingModule.sol";

contract AttachLicenseManager {
    LicensingModule public immutable LICENSING_MODULE;

    constructor(address licensingModuleAddress) {
        LICENSING_MODULE = LicensingModule(licensingModuleAddress);
    }

    function attachLicenseTerms(address ipId, address pilTemplate, uint256 licenseTermsId) external {
        LICENSING_MODULE.attachLicenseTerms(ipId, pilTemplate, licenseTermsId);
    }
}
