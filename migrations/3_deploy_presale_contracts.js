const Material = artifacts.require("Material");
const AccessoryProvider = artifacts.require("AccessoryProvider");
const MaterialProvider = artifacts.require("MaterialProvider");

const setupAccessories = require("../lib/presale/setupAccessories");

module.exports = async (deployer, network, addresses) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  //if (DEPLOY_ACCESSORIES) {
    await deployer.deploy(
      Material,
      proxyRegistryAddress,
      { gas: 5000000 }
    );
    await deployer.deploy(
      MaterialProvider,
      proxyRegistryAddress,
      Material.address,
      Material.address,
      { gas: 5000000 }
    );
    const accessories = await Material.deployed();
    const provider = await MaterialProvider.deployed();
    await setupAccessories.setupBuildingAccessories(
      accessories,
      provider,
      addresses[0]
    );
  //}

  // if (DEPLOY_ACCESSORIES_SALE) {
  //   await deployer.deploy(LootBoxRandomness);
  //   await deployer.link(LootBoxRandomness, BuildingAccessoryLootBox);
  //   await deployer.deploy(
  //     BuildingAccessoryLootBox,
  //     proxyRegistryAddress,
  //     { gas: 6721975 }
  //   );
  //   const lootBox = await BuildingAccessoryLootBox.deployed();
  //   await deployer.deploy(
  //     BuildingAccessoryProvider,
  //     proxyRegistryAddress,
  //     BuildingAccessory.address,
  //     BuildingAccessoryLootBox.address,
  //     { gas: 5000000 }
  //   );
  //   const accessories = await BuildingAccessory.deployed();
  //   const provider = await BuildingAccessoryProvider.deployed();
  //   await accessories.transferOwnership(
  //     BuildingAccessoryProvider.address
  //   );
  //   await setupBuildingAccessories.setupAccessoryLootBox(lootBox, provider);
  //   await lootBox.transferOwnership(provider.address);
  // }
};
