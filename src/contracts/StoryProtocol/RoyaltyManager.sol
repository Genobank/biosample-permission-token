// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RoyaltyModule } from "https://github.com/storyprotocol/protocol-core-v1/blob/main/contracts/modules/royalty/RoyaltyModule.sol";

contract RoyaltyManager {
    RoyaltyModule public immutable ROYALTY_MODULE;

    constructor(address royaltyModuleAddress) {
        ROYALTY_MODULE = RoyaltyModule(royaltyModuleAddress);
    }

    function payRoyalties(address childIpId, uint256 amount, address currencyToken) external {
        ROYALTY_MODULE.payRoyaltyOnBehalf(childIpId, address(0), currencyToken, amount);
    }
}
