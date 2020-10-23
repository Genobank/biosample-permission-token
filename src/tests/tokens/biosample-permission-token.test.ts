import { Spec } from '@specron/spec';

// Includes code from 0xcert at https://github.com/0xcert/ethereum-erc721/blob/master/src/tests/tokens/nf-token-metadata.test.ts

/**
 * Spec context interfaces.
 */

interface Data {
  nfToken?: any;
  owner?: string;
  bob?: string;
  jane?: string;
  bobId1?: string;
  uri1?: string;
}

/**
 * Spec stack instances.
 */

const spec = new Spec<Data>();

export default spec;

spec.beforeEach(async (ctx) => {
  const accounts = await ctx.web3.eth.getAccounts();
  ctx.set('owner', accounts[0]);
  ctx.set('bob', accounts[1]);
  ctx.set('jane', accounts[2]);
});

spec.beforeEach(async (ctx) => {
  const accounts = await ctx.web3.eth.getAccounts();
  ctx.set('bobId1', "0x000000000000000000000001" + accounts[1].substring(2)); // For bob's permission test
  ctx.set('uri1', 'http://0xcert.org/1');
});

spec.beforeEach(async (ctx) => {
  const nfToken = await ctx.deploy({ 
    src: './build/biosample-permission-token.json',
    contract: 'BiosamplePermissionToken',
    args: ['Foo','F']
  });
  ctx.set('nfToken', nfToken);
});

spec.test('correctly checks all the supported interfaces', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const nftokenInterface = await nftoken.instance.methods.supportsInterface('0x80ac58cd').call();
  const nftokenMetadataInterface = await nftoken.instance.methods.supportsInterface('0x5b5e139f').call();
  const nftokenNonExistingInterface = await nftoken.instance.methods.supportsInterface('0x780e9d63').call();
  ctx.is(nftokenInterface, true);
  ctx.is(nftokenMetadataInterface, true);
  ctx.is(nftokenNonExistingInterface, false);
});

spec.test('returns the correct issuer name', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const name = await nftoken.instance.methods.name().call();
  ctx.is(name, "Foo");
});

spec.test('returns the correct issuer symbol', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const symbol = await nftoken.instance.methods.symbol().call();
  ctx.is(symbol, "F");
});

spec.test('correctly mints a NFT', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');

  const logs = await nftoken.instance.methods.mint(bobId1, uri1).send({ from: bob });
  ctx.not(logs.events.Transfer, undefined);
  const tokenURI = await nftoken.instance.methods.tokenURI(bobId1).call();
  ctx.is(tokenURI, uri1);
});

spec.test('throws when person mints an unauthorized NFT ID', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');

  await ctx.reverts(() => nftoken.instance.methods.mint(bobId1, uri1).send({ from: jane }), 'TokenIds are namespaced to permitters');
});

spec.test('throws when trying to get URI of invalid NFT ID', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bobId1 = ctx.get('bobId1');

  await ctx.reverts(() => nftoken.instance.methods.tokenURI(bobId1).call(), '003002');
});
  
