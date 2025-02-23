// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {ZoraCreator1155FactoryImpl} from "zora-protocol/src/factory/ZoraCreator1155FactoryImpl.sol";
import {ZoraCreator1155Impl} from "zora-protocol/src/nft/ZoraCreator1155Impl.sol";
import {ZoraCreatorFixedPriceSaleStrategy} from "zora-protocol/src/minters/fixed-price/ZoraCreatorFixedPriceSaleStrategy.sol";
import {ZoraTest} from "../src/ZoraTest.sol";
import {Metadata} from "../src/Metadata.sol";

contract Deploy is Script {

  ZoraCreatorFixedPriceSaleStrategy internal fixedPrice;
  address[] internal rewardsRecipients;


  function setUp() public {
    //fixedPrice = new ZoraCreatorFixedPriceSaleStrategy();
    rewardsRecipients = new address[](1);
  }

  function run() public {

    console2.log("Setup contracts ---");
    
    uint256 deployer = vm.envUint("DEPLOYER_KEY");

    vm.startBroadcast(deployer);


    

    ZoraCreator1155FactoryImpl zoraFactory = ZoraCreator1155FactoryImpl(0x777777C338d93e2C7adf08D102d45CA7CC4Ed021);

    Metadata metadata = new Metadata();

    ZoraTest zoraTest = new ZoraTest(
      address(metadata),
      zoraFactory
    );

    address newEdition = zoraTest.createNewZoraEdition();
    uint256 tokenId = zoraTest.createNewEditionToken();
    address fixedPriceAddr = zoraTest.createFixedPrice();

    ZoraCreatorFixedPriceSaleStrategy fixedPrice = ZoraCreatorFixedPriceSaleStrategy(fixedPriceAddr);

    ZoraCreator1155Impl editionContract = ZoraCreator1155Impl(payable(newEdition));

    //editionContract.addPermission(tokenId, address(fixedPrice), editionContract.PERMISSION_BIT_MINTER());
    
    /*
    editionContract.callSale(
      tokenId, 
      fixedPrice, 
      abi.encodeWithSelector(
        ZoraCreatorFixedPriceSaleStrategy.setSale.selector,
        tokenId,
        ZoraCreatorFixedPriceSaleStrategy.SalesConfig({
          pricePerToken: 0.000000005 ether,
          saleStart: 0,
          saleEnd: type(uint64).max,
          maxTokensPerAddress: 0,
          fundsRecipient: address(this)
        })
      )
    );
    */

    uint256 numTokens = 2;
    //uint256 totalReward = editionContract.computeTotalReward(editionContract.mintFee(), numTokens);

    uint256 totalReward = 0.000111 ether * numTokens;
    uint256 totalValue = (0.000000005 ether * numTokens) + totalReward;

    //editionContract.mint{value: totalValue}(fixedPrice, tokenId, 10, abi.encode(deployer, ""));

    vm.stopBroadcast();

    console2.log("--------- CONTRACTS ADDRESSES ---------");
    console2.log("zora Impl: ", address(editionContract));
    console2.log("Metadata: ", address(metadata));
    console2.log("Zora Test: ", address(zoraTest));
    console2.log("New edition: ", address(newEdition));
    console2.log("Edition token ID: ", tokenId);

    //vm.broadcast();
  }
}
