// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IRenderer1155} from "zora-protocol/src/interfaces/IRenderer1155.sol";
import {Base64} from "solady/src/utils/Base64.sol";
import {LibString} from "solady/src/utils/LibString.sol";

contract Metadata is IRenderer1155 {
  string internal _uri;
  string internal _contractURI;

  function uri(uint256) external view returns (string memory) {
    bytes memory svg = abi.encodePacked(
      '<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg"> <rect x="0" y="0" width="500" height="500" fill="#FF0000"/>'
    );

    svg = abi.encodePacked(svg, "</svg>");

    string memory finalUri = string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name": "THE RED SQUARE TEST 3", "description": "hello hello, my sun.", "image":"data:image/svg+xml;base64,',
              Base64.encode(svg),
              '", "content":{"mime":"image/svg", "uri":"',
              Base64.encode (svg),
              '"}}'
            )
          )
        )
      )
    );

    return finalUri;

    //return "https://ipfs.io/ipfs/bafybeifqsbltzviwb4ntzxzkq2rrfm6vbdon4bed3tiv27uffhzqv4oawm";
  }

  function contractURI() external view returns (string memory) {
    return _contractURI;
  }

  function setup(bytes memory data) external override {
    if (data.length == 0) {
      revert();
    }
    _uri = string(data);
  }

  function setContractURI(string memory _newURI) external {
    _contractURI = _newURI;
  }

  function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    return interfaceID == type(IRenderer1155).interfaceId;
  }

}