const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CataDidNFT = artifacts.require("CataDidNFT");

module.exports = async function (deployer) {
  const existing = await CataDidNFT.deployed();
  await upgradeProxy(existing.address, CataDidNFT, { deployer });
};