// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Importa la interfaz de RoyaltyWorkflows
import { IRoyaltyWorkflows } from "https://github.com/storyprotocol/protocol-periphery-v1/blob/main/contracts/interfaces/workflows/IRoyaltyWorkflows.sol";

contract ExtendedRoyaltyManager {
    IRoyaltyWorkflows public immutable ROYALTY_WORKFLOWS;

    constructor(address royaltyWorkflowsAddress) {
        ROYALTY_WORKFLOWS = IRoyaltyWorkflows(royaltyWorkflowsAddress);
    }

    /// @notice Reclama regalías asociadas a un IP ancestral.
    function claimRoyalties(
        address ancestorIpId,
        address claimer,
        address[] calldata childIpIds,
        address[] calldata royaltyPolicies,
        address[] calldata currencyTokens,
        uint256[] calldata amounts
    ) external returns (uint256[] memory amountsClaimed) {
        amountsClaimed = ROYALTY_WORKFLOWS.transferToVaultAndClaimByTokenBatch(
            ancestorIpId,
            claimer,
            childIpIds,
            royaltyPolicies,
            currencyTokens,
            amounts
        );
    }
}
