// const METANFT = artifacts.require("METANFT");

// module.exports = function (deployer) {
//   deployer.deploy(METANFT);
// };


const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const METANFT = artifacts.require("METANFT");
const METANFT_v2 = artifacts.require("METANFT_v2");

module.exports = async function (deployer) {
  const existing = await METANFT.deployed();
  await upgradeProxy(existing.address, METANFT_v2, { deployer });
};