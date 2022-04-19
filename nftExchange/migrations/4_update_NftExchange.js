const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const NftExchange = artifacts.require("NftExchange");

module.exports = async function (deployer) {
  const existing = await NftExchange.deployed();
  // await upgradeProxy(existing.address, NftExchange, { deployer });
};