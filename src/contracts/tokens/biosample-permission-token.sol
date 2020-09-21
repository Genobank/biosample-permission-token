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

  /// TODO: description
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
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   * @param _uri String representing RFC 3986 URI.
   */
  function mint(
    uint256 _tokenId,
    address _receiverId,
    string calldata _permission
  )
    external
  {
    require(address(_tokenId) == msg.sender, "TokenIds are namespaced to permitters");
    NFToken._mint(_receiverId, _tokenId);
    NFTokenMetadata._setTokenUri(_tokenId, _permission);
    emit URI(_permission, _tokenId);
  }

  /**
   * @dev Set a permission for a given NFT ID.
   * @param _tokenId Id for which we want URI.
   * @param _uri String representing RFC 3986 URI.
   */
  function setTokenUri(
    uint256 _tokenId,
    string calldata _uri
  )
    external
  {
    require(address(_tokenId) == msg.sender, "TokenIds are namespaced to permitters");
    NFTokenMetadata._setTokenUri(_tokenId, _uri);
    emit URI(_uri, _tokenId);
  }

  
  /// TODO: add description
  function createWithSignature(
    uint256 _tokenId,
    string calldata _uri,
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
    NFTokenMetadata._setTokenUri(_tokenId, _uri);
    emit URI(_uri, _tokenId);
  }

  /// TODO: add description
  function setTokenUriWithSignature(
    uint256 _tokenId,
    string calldata _uri,
    uint256 _seed,
    bytes32 _signatureR,
    bytes32 _signatureS,
    uint8 _signatureV,
    SignatureKind _signatureKind
  )
    external
  {
    bytes32 _claim = getUpdateUriClaim(_tokenId, _uri, _seed);
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
    NFTokenMetadata._setTokenUri(_tokenId, _uri);
    emit URI(_uri, _tokenId);
  }

  /// TODO: add description
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

  /// TODO: add description
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

  /// TODO: add description
  function getUpdateUriClaim(
    uint256 _tokenId,
    string memory _uri,
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
        _uri,
        _seed
      )
    );
  }

}