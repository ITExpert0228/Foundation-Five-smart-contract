// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./AccessoryProvider.sol";
contract MaterialProvider is AccessoryProvider{
    constructor(
        address _proxyRegistryAddress,
        address _nftAddress,
        address _lootBoxAddress
    ) 
    AccessoryProvider(_proxyRegistryAddress, _nftAddress, _lootBoxAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        lootBoxAddress = _lootBoxAddress;
    }
    
    function name() override external pure returns (string memory) {
        return "Material Pre-Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "F5MNFT";
    }

    function supportsProviderInterface() override external pure returns (bool) {
        return true;
    }

    function providerSchemaName() override external pure returns (string memory) {
        return "ERC1155";
    }

    function numOptions() override external pure returns (uint256) {
        return 0;
    }

    function uri(uint256 _optionId) override external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    baseMetadataURI,
                    "provider/",
                    Strings.toString(_optionId)
                    )
                );
    }

    function canMint(uint256 _optionId, uint256 _amount)
        override
        external
        view
        returns (bool)
    {
        return _canMint(_msgSender(), _optionId, _amount);
    }
    function mint(
        uint256 _optionId,
        address _toAddress,
        uint256 _amount,
        bytes calldata _data
    )
    override external nonReentrant(){
        return _mint(_optionId, _toAddress, _amount, _data);
    }
    /**
     * @dev Main minting logic implemented here!
     */
    function _mint(
        uint256 _option,
        address _toAddress,
        uint256 _amount,
        bytes memory _data
    )   internal {
        require(
            _canMint(_msgSender(), _option, _amount),
            "BuildingAccessoryProvider#_mint: CANNOT_MINT_MORE"
        );
        _createOrMint(
                lootBoxAddress,
                _toAddress,
                _option,
                _amount,
                _data
            );
    }

    
    /**
     * Get the provider's ownership of Option.
     * Should be the amount it can still mint.
     * NOTE: Called by `canMint`
     */
    function balanceOf(address _owner, uint256 _optionId)
        override
        public
        view
        returns (uint256)
    {
        
    }
    function _canMint(
        address _fromAddress,
        uint256 _optionId,
        uint256 _amount
    ) internal view returns (bool) {
        return _amount > 0 && balanceOf(_fromAddress, _optionId) >= _amount;
    }
}