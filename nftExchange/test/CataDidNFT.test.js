const { expect } = require('chai');

const METANFT = artifacts.require('CataDidNFT');

contract('CataDidNFT', function ([owner, other]) {
  before(async function () {
    this.nft = await METANFT.new();
    await this.nft.initialize();
  });

  // Test case
  it('get nft name', async function () {
    expect((await this.nft.name()).toString()).to.equal('CataDidNFT');
  });

  it('test safeMint', async function () {
    let did = "com"
    await this.nft.safeMint(owner, did, { from: owner })
    expect((await this.nft.ownerOf(1)).toString()).to.equal(owner);
    expect((await this.nft.tokenURI(1)).toString()).to.equal(did);
    console.log((await this.nft.tokenURI(1)).toString())
  });

  it('test mintDid', async function () {
    let did = "aaa.com"
    await this.nft.mintDid(owner, did, { from: owner });
    expect((await this.nft.didOwner(did)).toString()).to.equal(owner);
    expect((await this.nft.getDids(owner)).toString()).to.equal("[\"com\",\"aaa.com\"]");
    console.log((await this.nft.getDids(owner)).toString())
  });
});