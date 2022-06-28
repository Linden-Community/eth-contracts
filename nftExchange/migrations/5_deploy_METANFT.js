const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CataDidNFT = artifacts.require("CataDidNFT");

module.exports = async function (deployer) {
  await deployProxy(CataDidNFT, [], { deployer, initializer: 'initialize' });
};