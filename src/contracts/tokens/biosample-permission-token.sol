pragma solidity 0.6.2;

import "../../../node_modules/@0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";


/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract BiosamplePermissionToken is
  NFTokenMetadata
{
  string namespace;

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
    string memory _symbol,
    string memory _namespace
  )
    public
  {
    nftName = _name;
    nftSymbol = _symbol;
    namespace = _namespace;

    // Mint existing tokens
    NFToken._mint(0x4d5dD2e41c226B63058dC1e972dDfD33415fE820, 0x000000000000000000000001633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x000000000000000000000001633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0xC8c06CbC1D4176A00081447bc9C0BEE970afaC8C, 0x00000000000000000000270f633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x00000000000000000000270f633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0xCef484DEB09B3dad49a51d3283C1e96809FAd2Bb, 0x000000000001000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x000000000001000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0xCef484DEB09B3dad49a51d3283C1e96809FAd2Bb, 0x00000000000100000000270fcef484deb09b3dad49a51d3283c1e96809fad2bb);
    NFTokenMetadata._setTokenUri(0x00000000000100000000270fcef484deb09b3dad49a51d3283c1e96809fad2bb, 'ACTIVE');

    NFToken._mint(0x82c182381560A5d62241f49321162d2C84911184, 0x01d656c0e675000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x01d656c0e675000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0x82c182381560A5d62241f49321162d2C84911184, 0x01d656c0e67500000000270f82c182381560a5d62241f49321162d2c84911184);
    NFTokenMetadata._setTokenUri(0x01d656c0e67500000000270f82c182381560a5d62241f49321162d2c84911184, 'ACTIVE');

    NFToken._mint(0xE068f8f195Ac72F03748e0b652db802D69Bc1Ec0, 0x00e8990a4600000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x00e8990a4600000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0xE068f8f195Ac72F03748e0b652db802D69Bc1Ec0, 0x00e8990a4600000000000001e068f8f195ac72f03748e0b652db802d69bc1ec0);
    NFTokenMetadata._setTokenUri(0x00e8990a4600000000000001e068f8f195ac72f03748e0b652db802d69bc1ec0, 'ACTIVE');

    NFToken._mint(0x4312Ae73e398df66FBcC2FA82C235B9B14fd3307, 0x01d656c0e67e000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x01d656c0e67e000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0x4312Ae73e398df66FBcC2FA82C235B9B14fd3307, 0x01d656c0e67e0000000000014312ae73e398df66fbcc2fa82c235b9b14fd3307);
    NFTokenMetadata._setTokenUri(0x01d656c0e67e0000000000014312ae73e398df66fbcc2fa82c235b9b14fd3307, 'ACTIVE');

    NFToken._mint(0x4B235F7B5c1b21a55fA0A88f98cC9efD16bD6Bb3, 0x01d656c0e67c000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x01d656c0e67c000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0x4B235F7B5c1b21a55fA0A88f98cC9efD16bD6Bb3, 0x01d656c0e67c0000000000014b235f7b5c1b21a55fa0a88f98cc9efd16bd6bb3);
    NFTokenMetadata._setTokenUri(0x01d656c0e67c0000000000014b235f7b5c1b21a55fa0a88f98cc9efd16bd6bb3, 'ACTIVE');

    NFToken._mint(0x6ce3C7AB2Dd4F4d7D1cF51cD0DB62C4952Ef80ae, 0x01d656c0e688000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x01d656c0e688000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0x6ce3C7AB2Dd4F4d7D1cF51cD0DB62C4952Ef80ae, 0x01d656c0e6880000000000016ce3c7ab2dd4f4d7d1cf51cd0db62c4952ef80ae);
    NFTokenMetadata._setTokenUri(0x01d656c0e6880000000000016ce3c7ab2dd4f4d7d1cf51cd0db62c4952ef80ae, 'ACTIVE');

    NFToken._mint(0xA866502223C3b995fbaB48A9dF939bcaD90c2Aa6, 0x01d656c0e677000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x01d656c0e677000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0xA866502223C3b995fbaB48A9dF939bcaD90c2Aa6, 0x01d656c0e677000000000001a866502223c3b995fbab48a9df939bcad90c2aa6);
    NFTokenMetadata._setTokenUri(0x01d656c0e677000000000001a866502223c3b995fbab48a9df939bcad90c2aa6, 'ACTIVE');

    NFToken._mint(0xbfE116a470F83465391c0c939db264Dea9777d12, 0x01d656c0e679000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184);
    NFTokenMetadata._setTokenUri(0x01d656c0e679000000000000633f5500a87c3dbb9c15f4d41ed5a33dacaf4184, 'ACTIVE');

    NFToken._mint(0xbfE116a470F83465391c0c939db264Dea9777d12, 0x01d656c0e679000000000001bfe116a470f83465391c0c939db264dea9777d12);
    NFTokenMetadata._setTokenUri(0x01d656c0e679000000000001bfe116a470f83465391c0c939db264dea9777d12, 'ACTIVE');
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
    view
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        namespace,
        ".create",
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
    view
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        namespace,
        ".permit",
        _tokenId,
        _permission,
        _seed
      )
    );
  }

}