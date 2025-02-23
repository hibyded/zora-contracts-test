// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Metadata} from "../src/Metadata.sol";

contract ZoraTest is Test {
  Metadata public metadata;

  function setUp() public {
    
    metadata = new Metadata();

  }

  function test_Uri() public {
    string memory tokenURI = metadata.uri(1);
    console2.log("TOKEN URI: ", tokenURI);
  }
}
