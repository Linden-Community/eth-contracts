const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const B3Token1155 = artifacts.require("B3Token");

module.exports = async function (deployer) {
  // await deployProxy(B3Token1155, [], { deployer, initializer: 'initialize' });
};