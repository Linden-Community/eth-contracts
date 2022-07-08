const { upgradeProxy, forceImport } = require('@openzeppelin/truffle-upgrades');

const CataDidNFT = artifacts.require("CataDidNFT");

module.exports = async function (deployer) {
  const existing = await CataDidNFT.deployed();
  // const instance = await forceImport(existing.address, CataDidNFT, {deployer});
  await upgradeProxy(existing.address, CataDidNFT, { deployer });
  // await upgradeProxy(instance.address, CataDidNFT, { deployer });
};