// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract GenobankEventNotarizer is AccessControl {
    string public tokenName;
    string public tokenSymbol;

    bytes32 public constant API_ROLE = keccak256("API_ROLE");

    struct Event {
        string actionType;
        string metadata;
        address actor;
        uint256 timestamp;
    }

    Event[] public events;

    event ActionNotarized(string actionType, string metadata, address indexed actor, uint256 timestamp);

    constructor(string memory _name, string memory _symbol) {
        tokenName = _name;
        tokenSymbol = _symbol;

        // Grant the API role to a specified address
        _grantRole(API_ROLE, msg.sender);

        // Grant the admin role to the contract deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function notarize(string memory actionType, string memory metadata) public {
        require(hasRole(API_ROLE, msg.sender), "Caller is not authorized");

        Event memory newEvent = Event({
            actionType: actionType,
            metadata: metadata,
            actor: msg.sender,
            timestamp: block.timestamp
        });
        
        events.push(newEvent);
        emit ActionNotarized(actionType, metadata, msg.sender, block.timestamp);
    }

    function getEvent(uint256 index) public view returns (string memory, string memory, address, uint256) {
        require(index < events.length, "Event index out of bounds");
        Event memory evt = events[index];
        return (evt.actionType, evt.metadata, evt.actor, evt.timestamp);
    }

    function getEventCount() public view returns (uint256) {
        return events.length;
    }

    function getAllEvents() public view returns (Event[] memory) {
        return events;
    }
}
