// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { LicensingModule } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/modules/licensing/LicensingModule.sol";

contract LicenseTokenManager {
    LicensingModule public immutable LICENSING_MODULE;

    constructor(address licensingModuleAddress) {
        LICENSING_MODULE = LicensingModule(licensingModuleAddress);
    }

    function mintLicenseToken(
        address licensorIpId,
        address licenseTemplate,
        uint256 licenseTermsId,
        address receiver,
        uint256 maxMintingFee
    ) external returns (uint256 licenseTokenId) {
        require(receiver != address(0), "Receiver address cannot be zero");

        licenseTokenId = LICENSING_MODULE.mintLicenseTokens({
            licensorIpId: licensorIpId,
            licenseTemplate: licenseTemplate,
            licenseTermsId: licenseTermsId,
            amount: 1,
            receiver: receiver,
            royaltyContext: "", 
            maxMintingFee: maxMintingFee
        });
    }

}
