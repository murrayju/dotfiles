import fs from 'fs-extra';
import * as path from 'path';
import { execSync } from 'child_process';
import * as os from 'os';
import { runInstaller } from './install-script.ts';

const HOME_DIR: string = os.homedir();
const PI_INSTALL_URL: string = 'https://pi.dev/install.sh';
// The pi installer's managed layout puts its launcher here.
const PI_BIN_DIR: string = path.join(HOME_DIR, '.pi/agent/bin');
const PI_LAUNCHER: string = path.join(PI_BIN_DIR, 'pi');

/** Return the path to an installed `pi`, if there is one. */
export function findPi(): string | undefined {
  for (const candidate of [
    PI_LAUNCHER,
    path.join(HOME_DIR, '.local/bin/pi'),
    path.join(HOME_DIR, 'bin/pi'),
  ]) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }
  try {
    const found = execSync('command -v pi', {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    if (found) {
      return found;
    }
  } catch {
    // `pi` is not on PATH.
  }
  return undefined;
}

/**
 * Install pi if it is not already present.
 *
 * `runInstaller` runs it without a controlling terminal, so its install/
 * reinstall/profile/start prompts take their default action.
 */
export default async function installPi(): Promise<void> {
  const existing = findPi();
  if (existing) {
    console.log(`✅ pi already installed (${existing})`);
    return;
  }

  console.log('Installing pi...');
  let status: number | null = null;
  try {
    status = await runInstaller(`curl -fsSL ${PI_INSTALL_URL} | sh`);
  } catch {
    status = -1;
  }

  if (status !== 0) {
    console.warn('⚠️  pi installation failed. Install it manually with:');
    console.warn(`  curl -fsSL ${PI_INSTALL_URL} | sh`);
    return;
  }

  const installed = findPi();
  if (installed) {
    console.log(`✅ pi installed (${installed})`);
    return;
  }
  console.log('✅ pi installed, but it is not on the PATH of this shell yet.');
  console.log(
    `  The dotfiles put ${PI_BIN_DIR} on $PATH; run \`reload\` or start a new shell.`,
  );
}
