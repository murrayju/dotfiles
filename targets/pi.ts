import fs from 'fs-extra';
import * as path from 'path';
import { execSync, spawn } from 'child_process';
import * as os from 'os';

const HOME_DIR: string = os.homedir();
const PI_INSTALL_URL: string = 'https://pi.dev/install.sh';
// The pi installer's managed layout puts its launcher here.
const PI_BIN_DIR: string = path.join(HOME_DIR, '.pi/agent/bin');
const PI_LAUNCHER: string = path.join(PI_BIN_DIR, 'pi');
const MISE_SHIMS: string = path.join(HOME_DIR, '.local/share/mise/shims');

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
 * Run the installer without letting it ask anything.
 *
 * The upstream installer is interactive by design: it asks whether to install
 * or reinstall, whether to add its bin directory to your shell profile, and
 * whether to start pi. Each of those prompts is guarded by a `/dev/tty` check,
 * so running the installer in its own session (`detached`, i.e. no controlling
 * terminal) makes it take its default action instead of prompting. stdin is
 * closed as well, so it cannot read from the user's terminal either. PATH gets
 * the mise shims first, so node/npm come from mise and the installer never
 * offers to install Node itself.
 */
function runInstaller(): Promise<number | null> {
  const env = { ...process.env };
  if (fs.existsSync(MISE_SHIMS)) {
    env.PATH = `${MISE_SHIMS}:${env.PATH ?? ''}`;
  }

  return new Promise((resolve, reject) => {
    const child = spawn(
      '/bin/sh',
      ['-c', `curl -fsSL ${PI_INSTALL_URL} | sh`],
      {
        stdio: ['ignore', 'inherit', 'inherit'],
        env,
        detached: true,
      },
    );

    // A detached child is in its own process group, so Ctrl-C on the bootstrap
    // would orphan it. Forward the signal instead.
    const forward = (signal: NodeJS.Signals) => child.kill(signal);
    process.on('SIGINT', forward);
    process.on('SIGTERM', forward);
    const cleanup = () => {
      process.off('SIGINT', forward);
      process.off('SIGTERM', forward);
    };

    child.on('error', (error) => {
      cleanup();
      reject(error);
    });
    child.on('exit', (code) => {
      cleanup();
      resolve(code);
    });
  });
}

/**
 * Install pi if it is not already present.
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
    status = await runInstaller();
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
