import { runCli, setPkg } from 'build-strap';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);

setPkg(require('../package.json'));

runCli({
  defaultAction: 'bootstrap',
  resolveFn: async (path: string) => import(`./${path}.ts`),
});
