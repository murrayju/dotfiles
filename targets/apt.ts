import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import * as os from 'os';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PACKAGE_LIST: string = path.join(__dirname, '..', 'packages', 'apt.txt');

function readPackages(): string[] {
  return fs
    .readFileSync(PACKAGE_LIST, 'utf8')
    .split('\n')
    .map((line) => line.replace(/#.*/, '').trim())
    .filter((line) => line.length > 0);
}

function isInstalled(pkg: string): boolean {
  try {
    const status = execFileSync('dpkg-query', ['-W', '-f=${Status}', pkg], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    });
    return status.includes('install ok installed');
  } catch {
    return false;
  }
}

function aptGet(args: string[]): void {
  const command = process.getuid?.() === 0 ? 'apt-get' : 'sudo';
  const argv = command === 'sudo' ? ['apt-get', ...args] : args;
  execFileSync(command, argv, { stdio: 'inherit' });
}

/**
 * Install the distro packages that the dotfiles rely on. Linux-only, opt-in
 * (`./bs apt`), and never part of the default bootstrap because it needs sudo.
 */
export default async function apt(): Promise<void> {
  if (os.platform() !== 'linux') {
    console.log('package: apt is only used on Linux, nothing to do.');
    return;
  }
  if (!fs.existsSync(PACKAGE_LIST)) {
    throw new Error(`package list not found: ${PACKAGE_LIST}`);
  }

  const packages = readPackages();
  const missing = packages.filter((pkg) => !isInstalled(pkg));

  if (missing.length === 0) {
    console.log(`✅ All ${packages.length} apt packages are installed.`);
    return;
  }

  console.log(
    `\n📦 Installing ${missing.length} apt package(s): ${missing.join(' ')}`,
  );
  aptGet(['update']);
  aptGet(['install', '-y', ...missing]);

  const stillMissing = missing.filter((pkg) => !isInstalled(pkg));
  if (stillMissing.length > 0) {
    throw new Error(`Failed to install: ${stillMissing.join(' ')}`);
  }
  console.log('✅ apt packages installed.');
}
