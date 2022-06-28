const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const METANFT = artifacts.require("METANFT");
const NftExchange = artifacts.require("NftExchange");

module.exports = async function (deployer) {
  // const nft = await METANFT.deployed();
  // await deployProxy(NftExchange, [86400, 15552000], { deployer, initializer: 'initialize' });
};