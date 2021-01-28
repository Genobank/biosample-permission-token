import { Spec } from '@specron/spec';

// Includes code from 0xcert at https://github.com/0xcert/ethereum-erc721/blob/master/src/tests/tokens/nf-token-metadata.test.ts

/**
 * Spec context interfaces.
 */

interface Data {
  emitter?: any;
  owner?: string;
  bob?: string;
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
});


spec.beforeEach(async (ctx) => {
  const emitter = await ctx.deploy({ 
    src: './build/emitter.json',
    contract: 'Emitter',
    args: []
  });
  ctx.set('emitter', emitter);
});

spec.test('Emits event', async (ctx) => {
  const emitter = ctx.get('emitter');
  const owner = ctx.get('owner');
  const logs = await emitter.instance.methods.emitClaim('Test').send({ from: owner });
  ctx.not(logs.events.Claim, undefined);
});
