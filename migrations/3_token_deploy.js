// migrations/2_deploy.js
const ownToken = artifacts.require('OwnToken');

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(ownToken);
};