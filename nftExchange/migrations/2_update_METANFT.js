const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const METANFT = artifacts.require("METANFT");

module.exports = async function (deployer) {
  const existing = await METANFT.deployed();
  await upgradeProxy(existing.address, METANFT, { deployer });
};