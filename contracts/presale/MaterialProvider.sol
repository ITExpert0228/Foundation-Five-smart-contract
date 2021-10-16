// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./AccessoryProvider.sol";
contract MaterialProvider is AccessoryProvider{

    uint256 constant NUM_ITEM_OPTIONS = 5;

    uint256 constant ID_M_NAIL = 1;
    uint256 constant ID_M_WOOD = 2;
    uint256 constant ID_M_PAINT = 3;
    uint256 constant ID_M_GLASS = 4;
    uint256 constant ID_M_METAL = 5;


    mapping(uint => uint256) public maxSupplies;
    mapping(uint => uint256) public prices;


    address public immutable deployer;

    bool public presaleLive;
    bool public saleLive;
    bool public locked;
    mapping(uint256 => mapping(address => uint256)) public presalerListPurchases;
    mapping(uint256 => uint256) public presalePurchaseLimit;
    mapping(string => bool) private _usedNonces;
    //ERC1155Tradable private nftContract;
    //ERC1155Tradable private lootBox;

    constructor(
        address _proxyRegistryAddress,
        address _nftAddress,
        address _lootBoxAddress
    ) 
    AccessoryProvider(_proxyRegistryAddress, _nftAddress, _lootBoxAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        lootBoxAddress = _lootBoxAddress;
        //nftContract = ERC1155Tradable(_nftAddress);
        //lootBox = ERC1155Tradable(_lootBoxAddress);

        maxSupplies[ID_M_NAIL] = 225000;
        maxSupplies[ID_M_WOOD] = 130000;
        maxSupplies[ID_M_PAINT] = 75000;
        maxSupplies[ID_M_GLASS] = 40000;
        maxSupplies[ID_M_METAL] = 60000;

        prices[ID_M_NAIL]   = 0.01 ether;
        prices[ID_M_WOOD]   = 0.02 ether;
        prices[ID_M_PAINT]  = 0.03 ether;
        prices[ID_M_GLASS]  = 0.05 ether;
        prices[ID_M_METAL]  = 0.07 ether;

        presalePurchaseLimit[ID_M_NAIL] = 225;
        presalePurchaseLimit[ID_M_WOOD] = 130;
        presalePurchaseLimit[ID_M_PAINT] = 75;
        presalePurchaseLimit[ID_M_GLASS] = 40;
        presalePurchaseLimit[ID_M_METAL] = 60;
        
        deployer = _msgSender();
    }
    
    function setPurchaseLimit(uint256 _option, uint256 _value) external onlyOwner onlyValidOption(_option) {
        presalePurchaseLimit[_option] = _value;
    }
    function setPrice(uint256 _option, uint256 _value) external onlyOwner onlyValidOption(_option) {
        prices[_option] = _value;
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
        return NUM_ITEM_OPTIONS;
    }

    function uri(uint256 _optionId) override external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    baseMetadataURI,
                    "materials/",
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
            "MaterialProvider#_mint: CANNOT_MINT_MORE"
        );
        require(_option<= NUM_ITEM_OPTIONS,"The type id is invalid");
        _createOrMint(
            nftAddress,
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
        if (!_isOwnerOrProxy(_owner) && _owner != lootBoxAddress) {
                // Only the provider's owner or owner's proxy,
                // or the lootbox can have supply
                return 0;
            }
            // The pre-minted balance belongs to the address that minted this contract
            ERC1155Tradable nftContract = ERC1155Tradable(nftAddress);
            // OptionId is used as a token ID here
            uint256 currentSupply = nftContract.balanceOf(owner(), _optionId);
            return currentSupply;
    }
    function _canMint(
        address _fromAddress,
        uint256 _optionId,
        uint256 _amount
    ) internal view returns (bool) {
        return _amount > 0 && balanceOf(_fromAddress, _optionId) >0;
    }
    function _presaleBuy(uint256 _option, uint256 tokenQuantity, bytes memory _data) internal onlyValidOption(_option) {
        address toBuyer = _msgSender();
        require(!saleLive && presaleLive, "PRESALE_CLOSED");
        require(tokenQuantity < balanceOf(owner(), _option), "OUT_OF_STOCK");
        require(presalerListPurchases[_option][toBuyer] + tokenQuantity <= presalePurchaseLimit[_option], "EXCEED_ALLOC");

        ERC1155Tradable items = ERC1155Tradable(nftAddress);
            // Option is used as a token ID here
            items.safeTransferFrom(
                owner(),
                toBuyer,
                _option,
                tokenQuantity,
                _data
            );
        presalerListPurchases[_option][toBuyer] += tokenQuantity;

    }
    function presaleBuy(uint256 _option, uint256 tokenQuantity, bytes memory _data) 
            external nonReentrant payable {

        require(prices[_option] * tokenQuantity <= msg.value, "INSUFFICIENT_ETH");
       _presaleBuy(_option,tokenQuantity, _data);
    }

    function presaleBuyBatch(uint256[] memory _ids,uint256[] memory _quantities, bytes memory _data) 
            external nonReentrant payable {
        uint256 totalPay = 0;
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            uint256 quantity = _quantities[i];
            totalPay += prices[_id] * quantity;
        }
        require(totalPay <= msg.value, "INSUFFICIENT_ETH");
        for (uint256 i = 0; i < _ids.length; i++) {
            _presaleBuy(_ids[i],_quantities[i], _data);
        }
    }
    /*
    function buy(bytes32 hash, bytes memory signature, string memory nonce, uint256 tokenQuantity) external payable {
        require(saleLive, "SALE_CLOSED");
        require(!presaleLive, "ONLY_PRESALE");
        require(matchAddresSigner(hash, signature), "DIRECT_MINT_DISALLOWED");
        require(!_usedNonces[nonce], "HASH_USED");
        require(hashTransaction(msg.sender, tokenQuantity, nonce) == hash, "HASH_FAIL");
        require(totalSupply() < SVS_MAX, "OUT_OF_STOCK");
        require(publicAmountMinted + tokenQuantity <= SVS_PUBLIC, "EXCEED_PUBLIC");
        require(tokenQuantity <= SVS_PER_MINT, "EXCEED_SVS_PER_MINT");
        require(SVS_PRICE * tokenQuantity <= msg.value, "INSUFFICIENT_ETH");
        
        for(uint256 i = 0; i < tokenQuantity; i++) {
            publicAmountMinted++;
            _safeMint(msg.sender, totalSupply() + 1);
        }
        
        _usedNonces[nonce] = true;
    }
    */
    modifier onlyValidOption(uint _option) {
        require(_option > 0 && _option < NUM_ITEM_OPTIONS, "Type ID is invalid");
        _;
    }
    modifier notLocked {
        require(!locked, "Contract metadata methods are locked");
        _;
    }
}