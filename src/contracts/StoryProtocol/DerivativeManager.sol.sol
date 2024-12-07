// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { LicensingModule } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/modules/licensing/LicensingModule.sol";

contract DerivativeManager {
    LicensingModule public immutable LICENSING_MODULE;

    constructor(address licensingModuleAddress) {
        LICENSING_MODULE = LicensingModule(licensingModuleAddress);
    }

    function registerDerivative(
        address childIpId,
        uint256[] calldata licenseTokenIds,
        uint32 maxRts
    ) external {
        require(childIpId != address(0), "Child IP ID cannot be zero address");
        require(licenseTokenIds.length > 0, "No license tokens provided");

        LICENSING_MODULE.registerDerivativeWithLicenseTokens({
            childIpId: childIpId,
            licenseTokenIds: licenseTokenIds,
            royaltyContext: "",
            maxRts: maxRts 
        });
    }
}
