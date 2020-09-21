import { Spec } from '@specron/spec';
import { getSignature } from '../helpers/signature';
import * as common from '../helpers/common';

// Includes code from 0xcert at https://github.com/0xcert/ethereum-erc721/blob/master/src/tests/tokens/nf-token-metadata.test.ts

/**
 * Spec context interfaces.
 */

interface Data {
  nfToken?: any;
  owner?: string;
  bob?: string;
  jane?: string;
  sara?: string;
  bobId1?: string;
  uri1?: string;
  uri2?: string;
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
  ctx.set('sara', accounts[3]);
});

spec.beforeEach(async (ctx) => {
  const accounts = await ctx.web3.eth.getAccounts();
  ctx.set('bobId1', "0x000000000000000000000001" + accounts[1].substring(2)); // For bob's permission test
  ctx.set('uri1', 'ACTIVE');
  ctx.set('uri2', 'INACTIVE');
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

  const logs = await nftoken.instance.methods.mint(bobId1, bob, uri1).send({ from: bob });
  ctx.not(logs.events.Transfer, undefined);
  const tokenURI = await nftoken.instance.methods.tokenURI(bobId1).call();
  ctx.is(tokenURI, uri1);
});

spec.test('correctly mints a NFT to a third party', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');

  const logs = await nftoken.instance.methods.mint(bobId1, jane, uri1).send({ from: bob });
  ctx.not(logs.events.Transfer, undefined);
  const tokenURI = await nftoken.instance.methods.tokenURI(bobId1).call();
  ctx.is(tokenURI, uri1);
  const owner = await nftoken.instance.methods.ownerOf(bobId1).call();
  ctx.is(owner, jane);
});

spec.test('correctly mints a NFT with signature', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');
  const seed = common.getCurrentTime();

  const claim = await nftoken.instance.methods.getCreateClaim(bobId1, seed).call();
  const signature = await getSignature(ctx.web3, claim, bob);
  
  const logs = await nftoken.instance.methods.createWithSignature(bobId1, uri1, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: jane });
  ctx.not(logs.events.Transfer, undefined);
  const tokenURI = await nftoken.instance.methods.tokenURI(bobId1).call();
  ctx.is(tokenURI, uri1);
});

spec.test('fails to mints a NFT with the same claim twice.', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');
  const seed = common.getCurrentTime();

  const claim = await nftoken.instance.methods.getCreateClaim(bobId1, seed).call();
  const signature = await getSignature(ctx.web3, claim, bob);
  
  await nftoken.instance.methods.createWithSignature(bobId1, uri1, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: jane });
  await ctx.reverts(() => nftoken.instance.methods.createWithSignature(bobId1, uri1, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: jane }), "Claim already used.");
});

spec.test('fails to mints a NFT with signature if signer is not the actor', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const sara = ctx.get('sara');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');
  const seed = common.getCurrentTime();

  const claim = await nftoken.instance.methods.getCreateClaim(bobId1, seed).call();
  const signature = await getSignature(ctx.web3, claim, jane);
  
  await ctx.reverts(() => nftoken.instance.methods.createWithSignature(bobId1, uri1, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: sara }), 'Signature is not valid.');
});

spec.test('throws when person mints an unauthorized NFT ID', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const jane = ctx.get('jane');
  const bob = ctx.get('bob');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');

  await ctx.reverts(() => nftoken.instance.methods.mint(bobId1, bob, uri1).send({ from: jane }), 'TokenIds are namespaced to permitters');
});

spec.test('throws when trying to get URI of invalid NFT ID', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bobId1 = ctx.get('bobId1');

  await ctx.reverts(() => nftoken.instance.methods.tokenURI(bobId1).call(), '003002');
});

spec.test('Updates uri with signature', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');
  const uri2 = ctx.get('uri2');
  const seed = common.getCurrentTime();

  await nftoken.instance.methods.mint(bobId1, bob, uri1).send({ from: bob });

  const claim = await nftoken.instance.methods.getUpdateUriClaim(bobId1, uri2, seed).call();
  const signature = await getSignature(ctx.web3, claim, bob);
  
  const logs = await nftoken.instance.methods.setTokenUriWithSignature(bobId1, uri2, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: jane });
  ctx.not(logs.events.URI, undefined);
  const tokenURI = await nftoken.instance.methods.tokenURI(bobId1).call();
  ctx.is(tokenURI, uri2);
});
  
spec.test('fails to update uri with signature if performed with the same claim twice', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const jane = ctx.get('jane');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');
  const uri2 = ctx.get('uri2');
  const seed = common.getCurrentTime();

  await nftoken.instance.methods.mint(bobId1, bob, uri1).send({ from: bob });

  const claim = await nftoken.instance.methods.getUpdateUriClaim(bobId1, uri2, seed).call();
  const signature = await getSignature(ctx.web3, claim, bob);
  
  await nftoken.instance.methods.setTokenUriWithSignature(bobId1, uri2, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: jane });
  await ctx.reverts(() => nftoken.instance.methods.setTokenUriWithSignature(bobId1, uri2, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: jane }), "Claim already used.");
});

spec.test('fails to update uri with signature if signed with different user then actor', async (ctx) => {
  const nftoken = ctx.get('nfToken');
  const bob = ctx.get('bob');
  const jane = ctx.get('jane');
  const sara = ctx.get('sara');
  const bobId1 = ctx.get('bobId1');
  const uri1 = ctx.get('uri1');
  const uri2 = ctx.get('uri2');
  const seed = common.getCurrentTime();

  await nftoken.instance.methods.mint(bobId1, bob, uri1).send({ from: bob });

  const claim = await nftoken.instance.methods.getUpdateUriClaim(bobId1, uri2, seed).call();
  const signature = await getSignature(ctx.web3, claim, jane);
  
  await ctx.reverts(() => nftoken.instance.methods.setTokenUriWithSignature(bobId1, uri2, seed, signature.r, signature.s, signature.v, signature.kind).send({ from: sara }), "Signature is not valid.");
});
  