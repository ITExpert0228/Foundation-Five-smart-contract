// migrations/2_deploy.js
const Box = artifacts.require('Box');

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Box);
};