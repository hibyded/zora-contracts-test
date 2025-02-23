// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ZoraCreator1155FactoryImpl} from "zora-protocol/src/factory/ZoraCreator1155FactoryImpl.sol";
import {ZoraCreator1155Impl} from "zora-protocol/src/nft/ZoraCreator1155Impl.sol";
import {Zora1155} from "zora-protocol/src/proxies/Zora1155.sol";
import {ICreatorRoyaltiesControl} from "zora-protocol/src/interfaces/ICreatorRoyaltiesControl.sol";
import {IZoraCreator1155} from "zora-protocol/src/interfaces/IZoraCreator1155.sol";
import {IRenderer1155} from "zora-protocol/src/interfaces/IRenderer1155.sol";
import {ZoraCreatorFixedPriceSaleStrategy} from "zora-protocol/src/minters/fixed-price/ZoraCreatorFixedPriceSaleStrategy.sol";


contract ZoraTest {
  ZoraCreator1155FactoryImpl public immutable zora1155Creator;

  ZoraCreator1155Impl private _editionCreated;
  ZoraCreatorFixedPriceSaleStrategy internal fixedPrice;
  address private _metadataAddress;
  uint256 private _tokenId;

  receive() external payable {}
  fallback() external payable {}

  constructor(
    address metadataAddress,
    ZoraCreator1155FactoryImpl _zora1155Creator
  ) {
    zora1155Creator = _zora1155Creator;
    _metadataAddress = metadataAddress;
  }

  function createNewZoraEdition() public returns (address) {
    Zora1155 zora1155 = Zora1155(payable(zora1155Creator.createContract(
      "", 
      "THE RED SQUARE TEST 3", 
      ICreatorRoyaltiesControl.RoyaltyConfiguration({
        royaltyMintSchedule: 0,
        royaltyBPS: 1,
        royaltyRecipient: msg.sender
      }), //defaultRoyaltyConfiguration, 
      payable(address(this)), 
      new bytes[](0)
    )));

    _editionCreated = ZoraCreator1155Impl(payable(address(zora1155)));

    _editionCreated.addPermission(0, msg.sender, _editionCreated.PERMISSION_BIT_ADMIN());
    _editionCreated.setOwner(msg.sender);

    return address(_editionCreated);
  }

  //wrong useless method, only for testing
  function createFixedPrice() external returns (address) {
    fixedPrice = new ZoraCreatorFixedPriceSaleStrategy();

    return address(fixedPrice);
  }

  function createNewEditionToken() public returns (uint256) {

    ZoraCreator1155Impl collection = _editionCreated;

    uint256 tokenId = collection.setupNewTokenWithCreateReferral(
      "",//"https://ipfs.io/ipfs/bafybeifqsbltzviwb4ntzxzkq2rrfm6vbdon4bed3tiv27uffhzqv4oawm", //URI
      30,
      address(0)
    );

    _tokenId = tokenId;

    collection.setTokenMetadataRenderer(tokenId, IRenderer1155(_metadataAddress));
    collection.addPermission(tokenId, address(fixedPrice), collection.PERMISSION_BIT_MINTER());

    return tokenId;
  }

  function createSale() external {
    ZoraCreator1155Impl collection = _editionCreated;

    collection.callSale(
      _tokenId, 
      fixedPrice, 
      abi.encodeWithSelector(
        ZoraCreatorFixedPriceSaleStrategy.setSale.selector,
        _tokenId,
        ZoraCreatorFixedPriceSaleStrategy.SalesConfig({
          pricePerToken: 0.000000005 ether,
          saleStart: 0,
          saleEnd: type(uint64).max,
          maxTokensPerAddress: 0,
          fundsRecipient: msg.sender
        })
      )
    );

  }

  function returnCollectionAddress() public view returns (address) {
    return address(_editionCreated);
  }
  
  function returnTokenCreated() public view returns (uint256) {
    return _tokenId;
  }
}
