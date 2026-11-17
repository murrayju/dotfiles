import fs from 'fs-extra';
import * as path from 'path';
import * as os from 'os';
import { runInstaller } from './install-script.ts';

const HOME_DIR: string = os.homedir();
const CN_INSTALL_URL: string =
  'https://raw.githubusercontent.com/concentrateai-hq/cli/main/install.sh';
// The installer puts its launcher in ~/.local/bin and marks it with this line,
// which tells our install apart from a different `cn` command.
const CN_LAUNCHER: string = path.join(HOME_DIR, '.local/bin/cn');
const CN_LAUNCHER_MARKER: string = '# concentrate-cli launcher';

/**
 * The directory cn keeps its state in.
 *
 * This follows `configDir` in cn: `CN_CONFIG_HOME`, else
 * `$XDG_CONFIG_HOME/concentrate-cli`, else `~/.config/concentrate-cli`. A
 * leading `~` is expanded to the home directory.
 */
export function concentrateConfigDir(): string {
  const expandHome = (value: string): string =>
    path.resolve(value.replace(/^~(?=$|\/)/, HOME_DIR));
  if (process.env.CN_CONFIG_HOME) {
    return expandHome(process.env.CN_CONFIG_HOME);
  }
  if (process.env.XDG_CONFIG_HOME) {
    return path.join(
      expandHome(process.env.XDG_CONFIG_HOME),
      'concentrate-cli',
    );
  }
  return path.join(HOME_DIR, '.config', 'concentrate-cli');
}

/** Return the path to an installed Concentrate launcher, if there is one. */
export function findConcentrate(): string | undefined {
  try {
    if (fs.readFileSync(CN_LAUNCHER, 'utf8').includes(CN_LAUNCHER_MARKER)) {
      return CN_LAUNCHER;
    }
  } catch {
    // No launcher, or it is not readable.
  }
  return undefined;
}

/**
 * Install the Concentrate CLI (`cn`) if it is not already present.
 *
 * The installer is piped into bash (it uses bash-only syntax) and needs
 * Node.js 22.13+; the mise shims on PATH provide it. `cn` puts its launcher in
 * ~/.local/bin, which the dotfiles already put on $PATH. Autorefresh of tools
 * set up with `cn configure` is skipped, so the bootstrap never prompts.
 */
export default async function installConcentrate(): Promise<void> {
  const existing = findConcentrate();
  if (existing) {
    console.log(`✅ Concentrate CLI already installed (${existing})`);
    return;
  }

  console.log('Installing Concentrate CLI (cn)...');
  let status: number | null = null;
  try {
    status = await runInstaller(`curl -fsSL ${CN_INSTALL_URL} | bash`, {
      CN_INSTALL_SKIP_REFRESH: '1',
    });
  } catch {
    status = -1;
  }

  if (status !== 0) {
    console.warn(
      '⚠️  Concentrate CLI installation failed. Install it manually with:',
    );
    console.warn(`  curl -fsSL ${CN_INSTALL_URL} | bash`);
    return;
  }

  const installed = findConcentrate();
  if (installed) {
    console.log(`✅ Concentrate CLI installed (${installed})`);
    return;
  }
  console.warn(
    '⚠️  Concentrate CLI install finished, but ~/.local/bin/cn is missing.',
  );
  console.warn('  Check it with `cn --version`, then reinstall if needed.');
}
