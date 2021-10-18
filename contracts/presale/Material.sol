// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC1155Tradable.sol";

/**
 * @title Material
 * Material - a contract for Building Accessory semi-fungible tokens.
 */
contract Material is ERC1155Tradable {
    string public contractURI ="https://buildings-api.opensea.io/contract/opensea-erc1155";
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _proxyRegistryAddress)
        ERC1155Tradable(
            _name,
            _symbol,
            _uri,
            _proxyRegistryAddress
        ) {}

    function setContractURI(string memory _contractURI) public onlyOwner {
        contractURI = _contractURI;
    }
}
