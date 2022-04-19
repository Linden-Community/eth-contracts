const { expect } = require('chai');

const METANFT = artifacts.require('METANFT');

contract('METANFT', function ([owner, other]) {
  beforeEach(async function () {
    this.nft = await METANFT.new();
    await this.nft.initialize();
  });

  // Test case
  it('get nft name', async function () {
    expect((await this.nft.name()).toString()).to.equal('METANFT');
  });

  it('test mint 1', async function () {
    await this.nft.safeMint(owner, 100)
    expect((await this.nft.ownerOf(100)).toString()).to.equal(owner);
    console.log((await this.nft.tokenURI(100)).toString())
  });

  it('test mint 2', async function () {
    await this.nft.safeMint(other, 101, "abcde")
    expect((await this.nft.ownerOf(101)).toString()).to.equal(other);
    console.log((await this.nft.tokenURI(101)).toString())
  });
});