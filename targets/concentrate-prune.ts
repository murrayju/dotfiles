import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import * as os from 'os';
import { fileURLToPath } from 'url';
import { findConcentrate } from './concentrate.ts';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const HOME_DIR: string = os.homedir();
const PRUNE_SOURCE: string = path.join(
  __dirname,
  '..',
  'bin',
  'pi-concentrate-prune',
);
const PRUNE_TARGET: string = path.join(HOME_DIR, 'bin', 'pi-concentrate-prune');
const MODELS_FILE: string = path.join(HOME_DIR, '.pi', 'agent', 'models.json');

/**
 * Install the Pi catalog pruner and refresh the Concentrate model list.
 *
 * `cn refresh` writes the full catalog into ~/.pi/agent/models.json. The pruner
 * then keeps the newest model of each chosen line. This process does not load
 * the shell wrapper that prunes after an interactive `cn` command, so prune
 * again here. `cn refresh` has no per-tool flag, so every configured tool is
 * refreshed.
 */
export default async function installConcentratePrune(): Promise<void> {
  fs.ensureDirSync(path.dirname(PRUNE_TARGET));
  fs.copySync(PRUNE_SOURCE, PRUNE_TARGET);
  fs.chmodSync(PRUNE_TARGET, 0o755);
  console.log(`✅ Concentrate pruner installed (${PRUNE_TARGET})`);

  const cn = findConcentrate();
  if (!cn) {
    console.warn(
      '⚠️  cn is not installed, so the model list was not refreshed.',
    );
    return;
  }
  if (!fs.existsSync(MODELS_FILE)) {
    console.log(
      'Pi has no Concentrate catalog yet. Run `cn configure pi` to create one.',
    );
    return;
  }

  console.log('Refreshing the Concentrate model list...');
  try {
    execFileSync(cn, ['refresh'], { stdio: 'inherit' });
  } catch {
    console.warn(
      '⚠️  cn refresh failed. The installed catalog was left as it is.',
    );
    return;
  }

  // Refresh writes the full catalog. Prune again here: this process does not
  // load the shell wrapper that prunes after an interactive `cn` command.
  try {
    execFileSync(PRUNE_TARGET, { stdio: 'inherit' });
  } catch {
    console.warn(
      '⚠️  Pruning the Pi model catalog failed. The full catalog is still in place.',
    );
  }
}
