const Web3 = require('web3');
const { expect } = require('chai');
const { BN } = require('@openzeppelin/test-helpers');

const METANFT = artifacts.require('METANFT');
const NftExchange = artifacts.require('NftExchange');

contract('NftExchange', function ([owner, other]) {
  before(async function () {
    this.ex = await NftExchange.new();
    this.nft = await METANFT.deployed();
    console.log("nft:", this.nft.address);
    await this.ex.initialize(86400, 15552000);
    await this.ex.addNftCode(this.nft.address)
  });

  // Test case
  it('get min duration', async function () {
    expect(await this.ex.getMinDuration()).to.be.bignumber.equal('86400');
  });

  it('test sell', async function () {
    let time = new Date().getTime() + 360000000;
    time = time.toString().substring(0, 10);
    await this.nft.safeMint(owner, 100)
    await this.nft.approve(this.ex.address, 100)
    await this.ex.sell(this.nft.address, 100, Web3.utils.toWei("0.1", "ether"), time);
    expect(await this.ex.getOffShelfTime(this.nft.address, 100)).to.be.bignumber.equal(time);
  });

  it('test buy', async function () {
    expect((await this.nft.ownerOf(100)).toString()).to.equal(owner)
    await this.ex.buy(this.nft.address, 100, { from: other, value: Web3.utils.toWei("0.1", "ether") });
    expect((await this.nft.ownerOf(100)).toString()).to.equal(other)
  });
});