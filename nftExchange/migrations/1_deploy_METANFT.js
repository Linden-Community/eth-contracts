const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const METANFT = artifacts.require("METANFT");

module.exports = async function (deployer) {
  // await deployProxy(METANFT, [], { deployer, initializer: 'initialize' });
};