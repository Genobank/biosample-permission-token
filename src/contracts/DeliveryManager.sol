// SPDX-License-Identifier: MIT
pragma solidity = 0.8.9;
import "./USDNA.sol";

contract DeliveryManager {
    address contractAdministrator;
    USDNA public usdna;
    uint256 public constant transferAmount = 450 * 10**18;

    struct FileDetails {
        uint256 biosampleSerial;
        address owner;
        address lab;
        uint createdAt;
    }
    
    mapping (address => mapping(uint256 => FileDetails)) public fileDetails;
    
    event logFileDeliveredStatus(bool status, uint256 biosampleSerial, address owner, uint timestamp, address lab);
    
    constructor(address _usdnaAddress){
        contractAdministrator = msg.sender;
        usdna = USDNA(_usdnaAddress);
    }

    function delivery(uint256 biosampleSerial, address owner, address lab) public {
        require (msg.sender == contractAdministrator || msg.sender == lab, "You do not have permissions to call this function");
        require (msg.sender != owner, "You do not have permissions to call this function");
        require (lab != owner, "You can't deliver the file yourself");
        fileDetails[lab][biosampleSerial] = FileDetails(biosampleSerial, owner, lab, block.timestamp);
         // Transfiere los tokens USDNA al propietario
        require(usdna.transferFrom(contractAdministrator, owner, transferAmount), "Transfer failed");
        emit logFileDeliveredStatus(true, biosampleSerial, owner, block.timestamp, lab);

       
    }
    
    function get(address laboratory, uint256 serial) public view returns (uint timestamp, address owner, address lab) {
        return (fileDetails[laboratory][serial].createdAt, fileDetails[laboratory][serial].owner, fileDetails[laboratory][serial].lab);
    }
}