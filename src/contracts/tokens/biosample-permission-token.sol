pragma solidity 0.6.2;

import "../../../node_modules/@0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";


/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract BiosamplePermissionToken is
  NFTokenMetadata
{
  /**
   * @dev MUST emit when the URI is updated for a token ID.
   * URIs are defined in RFC 3986.
   * Inspired by ERC-1155
   */
  event URI(string _value, uint256 indexed _tokenId);

  /**
   * @dev Enum representing supported signature kinds.
   */
  enum SignatureKind
  {
    no_prefix,
    eth_sign
  }

  /**
   * @dev Mapping of all used claims.
   */
  mapping(bytes32 => bool) public usedClaims;

  /**
   * @dev Contract constructor.
   * @param _name A descriptive name for a collection of NFTs.
   * @param _symbol An abbreviated name for NFTokens.
   */
  constructor(
    string memory _name,
    string memory _symbol
  )
    public
  {
    nftName = _name;
    nftSymbol = _symbol;
  }

  /// TODO: fix description
  /**
   * @dev Mints a new NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   * @param _receiverId The address that will own the minted NFT.
   * @param _permission String representing permission.
   */
  function mint(
    uint256 _tokenId,
    address _receiverId,
    string calldata _permission
  )
    external
  {
    require(address(_tokenId) == msg.sender, "TokenIds are namespaced to permitters");
    NFToken._mint(msg.sender, _tokenId);
    NFTokenMetadata._setTokenUri(_tokenId, _permission);
    emit URI(_permission, _tokenId);
    if (msg.sender != _receiverId) {
      NFToken._transfer(_receiverId, _tokenId);
    }
  }

  /**
   * @dev Set a permission for a given NFT ID.
   * @param _tokenId Id for which we want URI.
   * @param _permission String representing permission.
   */
  function setTokenUri(
    uint256 _tokenId,
    string calldata _permission
  )
    external
  {
    require(address(_tokenId) == msg.sender, "TokenIds are namespaced to permitters");
    NFTokenMetadata._setTokenUri(_tokenId, _permission);
    emit URI(_permission, _tokenId);
  }

  /**
   * @dev Mints token in the name of signature provider.
   * @param _tokenId of the NFT that will be minted.
   * @param _permission String representing permission.
   * @param _seed Parameter to create hash randomnes (usually timestamp).
   * @param _signatureR Parameter R of the signature.
   * @param _signatureS Parameter S of the signature.
   * @param _signatureV Parameter V of the signature.
   * @param _signatureKind Signature kind.
   */
  function createWithSignature(
    uint256 _tokenId,
    string calldata _permission,
    uint256 _seed,
    bytes32 _signatureR,
    bytes32 _signatureS,
    uint8 _signatureV,
    SignatureKind _signatureKind
  )
    external
  {
    bytes32 _claim = getCreateClaim(_tokenId, _seed);
    require(
      isValidSignature(
        address(_tokenId),
        _claim,
        _signatureR,
        _signatureS,
        _signatureV,
        _signatureKind
      ),
      "Signature is not valid."
    );
    require(!usedClaims[_claim], "Claim already used.");
    usedClaims[_claim] = true;
    NFToken._mint(address(_tokenId), _tokenId);
    NFTokenMetadata._setTokenUri(_tokenId, _permission);
    emit URI(_permission, _tokenId);
  }

  /**
   * @dev Set a permission for a given NFT ID in the name of signature provider.
   * @param _tokenId of the NFT which permission will get set.
   * @param _permission String representing permission.
   * @param _seed Parameter to create hash randomnes (usually timestamp).
   * @param _signatureR Parameter R of the signature.
   * @param _signatureS Parameter S of the signature.
   * @param _signatureV Parameter V of the signature.
   * @param _signatureKind Signature kind.
   */
  function setTokenUriWithSignature(
    uint256 _tokenId,
    string calldata _permission,
    uint256 _seed,
    bytes32 _signatureR,
    bytes32 _signatureS,
    uint8 _signatureV,
    SignatureKind _signatureKind
  )
    external
  {
    bytes32 _claim = getUpdateUriClaim(_tokenId, _permission, _seed);
    require(
      isValidSignature(
        address(_tokenId),
        _claim,
        _signatureR,
        _signatureS,
        _signatureV,
        _signatureKind
      ),
      "Signature is not valid."
    );
    require(!usedClaims[_claim], "Claim already used.");
    usedClaims[_claim] = true;
    NFTokenMetadata._setTokenUri(_tokenId, _permission);
    emit URI(_permission, _tokenId);
  }

  /**
   * @dev Cheks if signature is indeed provided by the signer.
   * @param _signer Address of the signer.
   * @param _claim Claim that was signed.
   * @param _r Parameter R of the signature.
   * @param _s Parameter S of the signature.
   * @param _v Parameter V of the signature.
   * @param _kind Signature kind.
   */
  function isValidSignature(
    address _signer,
    bytes32 _claim,
    bytes32 _r,
    bytes32 _s,
    uint8 _v,
    SignatureKind _kind
  )
    public
    pure
    returns (bool)
  {
    if (_kind == SignatureKind.no_prefix) {
      return _signer == ecrecover(
        _claim,
        _v,
        _r,
        _s
      );
    } else if (_kind == SignatureKind.eth_sign) {
      return _signer == ecrecover(
          keccak256(
            abi.encodePacked(
              "\x19Ethereum Signed Message:\n32",
              _claim
            )
          ),
          _v,
          _r,
          _s
        );
    } else {
      revert("Invalid signature kind.");
    }
  }

  /**
   * @dev Generates claim for creating a token.
   * @param _tokenId of the NFT we are creating.
   * @param _seed Parameter to create hash randomnes (usually timestamp).
   */
  function getCreateClaim(
    uint256 _tokenId,
    uint256 _seed
  )
    public
    pure
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        "io.genobank.test.create",
        _tokenId,
        _seed
      )
    );
  }

 /**
   * @dev Generates claim for updating a token permission.
   * @param _tokenId of the NFT we are updating permission.
   * @param _permission String representing permission.
   * @param _seed Parameter to create hash randomnes (usually timestamp).
   */
  function getUpdateUriClaim(
    uint256 _tokenId,
    string memory _permission,
    uint256 _seed
  )
    public
    pure
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        "io.genobank.test.permit",
        _tokenId,
        _permission,
        _seed
      )
    );
  }

}