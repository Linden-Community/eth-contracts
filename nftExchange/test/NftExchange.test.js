const Web3 = require('web3');
const { expect } = require('chai');
const { BN } = require('@openzeppelin/test-helpers');

const METANFT = artifacts.require('METANFT');
const NftExchange = artifacts.require('NftExchange');

contract('NftExchange', function ([owner, other]) {
  beforeEach(async function () {
    this.ex = await NftExchange.new();
    this.nft = await METANFT.deployed();
    console.log("nft:", this.nft.address);
    await this.ex.initialize(this.nft.address, 86400, 15552000);
  });

  // Test case
  it('get min duration', async function () {
    expect(await this.ex.getMinDuration()).to.be.bignumber.equal('86400');
  });

  it('test sell', async function () {
    let time = new Date().getTime() + 360000000;
    time = time.toString().substring(0,10);
    await this.nft.safeMint(owner, 100)
    await this.ex.sell(100, Web3.utils.toWei("0.1", "ether"), time);
    expect(await this.ex.getOffShelfTime(100)).to.be.bignumber.equal(time);
  });
});