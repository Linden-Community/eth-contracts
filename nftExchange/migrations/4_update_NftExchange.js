const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const AiToken721 = artifacts.require("AiToken");

module.exports = async function (deployer) {
  const existing = await AiToken721.deployed();
  await upgradeProxy(existing.address, AiToken721, { deployer });
};