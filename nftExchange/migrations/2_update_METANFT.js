const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const B3Token1155 = artifacts.require("B3Token");

module.exports = async function (deployer) {
  const existing = await B3Token1155.deployed();
  // await upgradeProxy(existing.address, B3Token1155, { deployer });
};