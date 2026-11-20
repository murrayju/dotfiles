import fs from 'fs-extra';
import * as path from 'path';
import { execSync } from 'child_process';
import * as os from 'os';
import { runUnattended } from './install-script.ts';

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
 * Return `env` with the directory that holds the pi launcher first on `PATH`.
 *
 * cn finds a tool with a plain `PATH` search. The bootstrap does not load the
 * shell profile, so cn cannot see `pi` without this.
 */
export function withPiOnPath(env: NodeJS.ProcessEnv): NodeJS.ProcessEnv {
  const pi = findPi();
  if (!pi) {
    return env;
  }
  return {
    ...env,
    PATH: `${path.dirname(pi)}${path.delimiter}${env.PATH ?? ''}`,
  };
}

/**
 * Install pi if it is not already present, then update pi and its packages.
 *
 * `runUnattended` runs both without a controlling terminal, so a prompt takes
 * its default action instead of waiting for input.
 */
export default async function installPi(): Promise<void> {
  if (!(await ensurePiInstalled())) {
    return;
  }
  await updatePi();
}

/** Install pi when it is missing. Returns true when pi is present afterwards. */
async function ensurePiInstalled(): Promise<boolean> {
  const existing = findPi();
  if (existing) {
    console.log(`✅ pi already installed (${existing})`);
    return true;
  }

  console.log('Installing pi...');
  let status: number | null = null;
  try {
    status = await runUnattended(`curl -fsSL ${PI_INSTALL_URL} | sh`);
  } catch {
    status = -1;
  }

  if (status !== 0) {
    console.warn('⚠️  pi installation failed. Install it manually with:');
    console.warn(`  curl -fsSL ${PI_INSTALL_URL} | sh`);
    return false;
  }

  const installed = findPi();
  if (installed) {
    console.log(`✅ pi installed (${installed})`);
    return true;
  }
  console.log('✅ pi installed, but it is not on the PATH of this shell yet.');
  console.log(
    `  The dotfiles put ${PI_BIN_DIR} on $PATH; run \`reload\` or start a new shell.`,
  );
  return true;
}

// `pi update` updates pi itself; installed packages need their own pass.
const PI_UPDATE_ARGV: string[][] = [['update'], ['update', '--extensions']];

/**
 * Update pi and its installed packages to the latest versions.
 *
 * A bootstrap on a machine that already has pi should not leave it stale. Both
 * commands are best-effort: an offline machine, a package manager that owns
 * pi, or a failing npm must only warn, because the rest of the bootstrap still
 * has work to do.
 */
async function updatePi(): Promise<void> {
  const pi = findPi();
  if (!pi) {
    console.warn('⚠️  Could not find pi, so it was not updated.');
    console.warn('  Run `reload`, then `pi update && pi update --extensions`.');
    return;
  }

  console.log('Updating pi and its packages...');
  for (const argv of PI_UPDATE_ARGV) {
    let status: number | null = null;
    try {
      // The path is quoted because it comes from the home directory name.
      status = await runUnattended(`"${pi}" ${argv.join(' ')}`);
    } catch {
      status = -1;
    }
    if (status !== 0) {
      console.warn(
        `⚠️  \`pi ${argv.join(' ')}\` failed. Run it by hand to update pi.`,
      );
    }
  }
}
