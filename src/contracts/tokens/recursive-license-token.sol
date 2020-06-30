pragma solidity 0.6.2;

import "../../../node_modules/@0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";


/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract RecursiveLicenseToken is
  NFTokenMetadata
{
  /**
   * @dev MUST emit when the URI is updated for a token ID.
   * URIs are defined in RFC 3986.
   * Inspired by ERC-1155
   */
  event URI(string _value, uint256 indexed _tokenId);


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

  /**
   * @dev Mints a new NFT.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   * @param _uri String representing RFC 3986 URI.
   */
  function mint(
    uint256 _tokenId,
    string calldata _permission
  )
    external
  {
    require(address(_tokenId) == msg.sender, "TokenIds are namespaced to licensors");
    NFToken._mint(msg.sender, _tokenId);
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
    require(address(_tokenId) == msg.sender, "TokenIds are namespaced to licensors");
    NFTokenMetadata._setTokenUri(_tokenId, _uri);
    emit URI(_uri, _tokenId);
  }  

}