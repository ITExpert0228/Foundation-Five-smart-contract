// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "../IProviderERC1155.sol";
import "../ERC1155Tradable.sol";

/**
 * @title AccessoryProvider
 * AccessoryProvider - a provider contract for Building Accessory semi-fungible
 * tokens.
 */
abstract contract AccessoryProvider is ProviderERC1155, Ownable, ReentrancyGuard {
    using Strings for string;
    using SafeMath for uint256;

    address public proxyRegistryAddress;
    address public nftAddress;
    address public lootBoxAddress;
    string  public baseMetadataURI = "https://buildings-api.opensea.io/api/";
    uint256 constant UINT256_MAX = ~uint256(0);

    /*
     * Optionally set this to a small integer to enforce limited existence per option/token ID
     * (Otherwise rely on sell orders on OpenSea, which can only be made by the provider owner.)
     */
    uint256 constant SUPPLY_PER_TOKEN_ID = UINT256_MAX;

    constructor(
        address _proxyRegistryAddress,
        address _nftAddress,
        address _lootBoxAddress
    ) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        lootBoxAddress = _lootBoxAddress;
    }
    
    function setBaseMetadataURI(string memory _uri) public onlyOwner{
        baseMetadataURI = _uri;
    }

    /*
     * Note: make sure code that calls this is non-reentrant.
     * Note: this is the token _id *within* the ERC1155 contract, not the option
     *       id from this contract.
     */
    function _createOrMint(
        address _erc1155Address,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {
        ERC1155Tradable tradable = ERC1155Tradable(_erc1155Address);
        // Lazily create the token
        if (!tradable.exists(_id)) {
            tradable.create(_to, _id, _amount, "", _data);
        } else {
            tradable.mint(_to, _id, _amount, _data);
        }
    }

    function _isOwnerOrProxy(address _address) internal view returns (bool) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return
            owner() == _address ||
            address(proxyRegistry.proxies(owner())) == _address;
    }
}
