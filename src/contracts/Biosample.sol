// SPDX-License-Identifier: MIT
pragma solidity = 0.8.9;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";



contract BiosampleDataNFT is ERC1155, Ownable{
	using Counters for Counters.Counter;
	Counters.Counter private internalFileSerial;
	uint counter;
	address public contractAdministrator;
	uint uniqueTokenIDCounter;
	enum Status { ACTIVE, REVOKED, DELETED }
	struct File {
		uint tokenId;
		string name;
		address owner;
		address laboratory;
		bool enable;
		Status status;
		uint expiration;
		address actor;
		uint createdAt;
	}
	event Transferconsent (address _user, address _permittee, uint _tokenId);
	event UploadFile (address _user, uint _tokenId);
	event RevokeAccess (address _user, address _permittee, uint _tokenId);
	event DeleteFile (address _user, address permittee, uint _tokenId);
	mapping (address => File[]) public ownerToFileList;
	mapping (address => File[]) public labToFileList;
	mapping (uint256 => uint256) public biosampleToOwnerFileIndex;
	mapping (address => mapping (uint256 => uint256)) public biosampleToLabFileIndex;
	mapping(uint256 => bool) public biosampleSerialExists;
	mapping(uint256 => mapping(address => bool)) public biosampleSharedWithPermittee;
	
	constructor (string memory _uri) ERC1155(_uri){
		contractAdministrator = msg.sender; // Replace with the actual administrator address
		internalFileSerial.increment(); // we need this if we want to start the token id from 1 instead from 0
	}
	
	function uploadFile(
		string memory _name,
		address _fileOwner,
		uint _expiration
	) public returns (uint){
		require (msg.sender == contractAdministrator, "Only the contract administrator can call this function");
		require (!isStringEmpty(_name), "Your file name is empty");
		File memory newFile = File(
			internalFileSerial.current(),
			_name,
			_fileOwner,
			address(0),
			true,
			Status.ACTIVE,
			_expiration,
			msg.sender,
			block.timestamp
		);
		ownerToFileList[_fileOwner].push(newFile);
		biosampleToOwnerFileIndex[internalFileSerial.current()] = ownerToFileList[_fileOwner].length - 1;
		biosampleSerialExists[internalFileSerial.current()] = true;
		internalFileSerial.increment(); 
		emit UploadFile(_fileOwner, internalFileSerial.current());
		return internalFileSerial.current();

	}
	
	function shareFile(
		uint256 _biosampleHash,
		address _fileOwner,
		address _permittee,
		uint _expiration
	) public {
		require(msg.sender == contractAdministrator || msg.sender == _fileOwner,  "Only the contract administrator can call this function");
		require(ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].status == Status.ACTIVE && block.timestamp <= ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].expiration, "This biosample is not active or has already expired");
		require (!biosampleSharedWithPermittee[_biosampleHash][_permittee], "You already have share this file with this permittee");
		File memory fileToShare = ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]];
		fileToShare.laboratory = _permittee;
		fileToShare.expiration = _expiration;
		fileToShare.createdAt = block.timestamp;
		labToFileList[_permittee].push(fileToShare);
		biosampleToLabFileIndex[_permittee][_biosampleHash] = labToFileList[_permittee].length-1;
		ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].laboratory = _permittee;
		bytes memory bytesPermittee = toBytes(_permittee);
		bytes memory bytesFileOwner = toBytes(_fileOwner);
		_mint(_fileOwner, _biosampleHash, 1, bytesPermittee);
		_mint(_permittee, _biosampleHash, 1, bytesFileOwner);
		emit Transferconsent(_fileOwner, _permittee, _biosampleHash);
		biosampleSharedWithPermittee[_biosampleHash][_permittee] = true;
	}

	function revokeAccess(
		uint _biosampleHash,
		address _fileOwner,
		address _permittee
	) public returns (uint){
		require(msg.sender == contractAdministrator || msg.sender == _fileOwner, "Only the contract administrator can call this function");
		require (biosampleSerialExists[_biosampleHash], "This Biosfile does not exist");
		require (biosampleSharedWithPermittee[_biosampleHash][_permittee], "You need to share this file to be able to revoke");
		require(ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].status == Status.ACTIVE && block.timestamp <= ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].expiration, "This biosample is not active or has already expired");
		ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].status = Status.REVOKED;
		labToFileList[_permittee][biosampleToLabFileIndex[_permittee][_biosampleHash]].status = Status.REVOKED;
		return _biosampleHash;
	}

	function deleteFile(
		uint256 _biosampleHash,
		address _fileOwner,
		address _permittee
	) public returns (uint){
		require(msg.sender == contractAdministrator || msg.sender == _fileOwner, "Only the contract administrator can call this function");
		ownerToFileList[_fileOwner][biosampleToOwnerFileIndex[_biosampleHash]].status = Status.DELETED;
		labToFileList[_permittee][biosampleToLabFileIndex[_permittee][_biosampleHash]].status = Status.DELETED;
		return _biosampleHash;
	}

	function getMyFiles(
	) public view returns (File [] memory){
		return ownerToFileList[msg.sender];
	}

	function getFilesFromOwnerAddress (
		address _fileOwner
	) public view returns (File [] memory){
		return ownerToFileList[_fileOwner];
	}
	
	function getSharedFilesWithPermittee(
		address _permittee
	) public view returns(File [] memory){
		return labToFileList[_permittee];
	}
	
	function checkFileStatus(
		address _fileOwner,
		uint _index
	) public view returns(bool){
		return ownerToFileList[_fileOwner][_index].enable;
	}

	//utils
	function isPermittee(
		address _wallet
	) public view returns(bool){
		bool ispermittee = false;
		if (labToFileList[_wallet].length != 0){
			if (!isStringEmpty(labToFileList[_wallet][0].name)){
				ispermittee = true;
			}
		}
		return ispermittee;
	}

	function isStringEmpty(
		string memory value
	) internal pure returns(bool){
		bytes memory str = bytes(value);
		for (uint i=0; i<str.length; i++){
			if(str[i] != ' '){
				return false;
			}
		}
		return true;
	}
	
	function toBytes(
		address a
	) public pure returns(bytes memory b){
		assembly {
			let m := mload(0x40)
			a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
			mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
			mstore(0x40, add(m, 52))
			b := m
		}
	}
}