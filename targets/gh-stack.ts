import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import * as os from 'os';

const EXTENSION_NAME = 'gh stack';
const EXTENSION_REPO = 'github/gh-stack';

/** Build an environment with mise shims on PATH and interactive prompts off. */
function ghEnvironment(): NodeJS.ProcessEnv {
  const env: NodeJS.ProcessEnv = {
    ...process.env,
    GH_PROMPT_DISABLED: '1',
    GIT_TERMINAL_PROMPT: '0',
  };
  const miseShims = path.join(os.homedir(), '.local/share/mise/shims');
  if (fs.existsSync(miseShims)) {
    env.PATH = `${miseShims}${path.delimiter}${env.PATH ?? ''}`;
  }
  return env;
}

type ExtensionState =
  | { kind: 'missing' }
  | { kind: 'installed' }
  | { kind: 'conflict'; repo: string };

/** Inspect `gh extension list` to see whether `github/gh-stack` is installed. */
function inspectExtension(env: NodeJS.ProcessEnv): ExtensionState | undefined {
  let output: string;
  try {
    output = execFileSync('gh', ['extension', 'list'], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
      env,
    });
  } catch {
    return undefined;
  }

  for (const line of output.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed) {
      continue;
    }
    const [name = '', repo = ''] = trimmed.split('\t');
    if (repo.toLowerCase() === EXTENSION_REPO) {
      return { kind: 'installed' };
    }
    if (name === EXTENSION_NAME) {
      return { kind: 'conflict', repo: repo || 'unknown' };
    }
  }
  return { kind: 'missing' };
}

/**
 * Install or upgrade the official GitHub CLI `gh stack` extension.
 *
 * `gh` comes from mise, so this puts the mise shims ahead of PATH and runs
 * after `installMiseTools()`. Failures (offline, unauthenticated, or missing
 * `gh`) warn without stopping the rest of the bootstrap.
 */
export default async function installGhStack(): Promise<void> {
  const env = ghEnvironment();
  const state = inspectExtension(env);
  if (!state) {
    console.warn(
      '⚠️  Skipping gh-stack: `gh` is not available or could not list extensions.',
    );
    return;
  }

  if (state.kind === 'conflict') {
    console.warn(
      `⚠️  Skipping gh-stack: "${EXTENSION_NAME}" is already provided by ${state.repo}.`,
    );
    return;
  }

  if (state.kind === 'installed') {
    console.log('Updating gh-stack extension...');
    try {
      execFileSync('gh', ['extension', 'upgrade', 'stack'], {
        stdio: ['ignore', 'inherit', 'inherit'],
        env,
      });
      console.log('✅ gh-stack is up to date');
    } catch {
      console.warn(
        '⚠️  Could not upgrade gh-stack (offline or unauthenticated). Update it by hand with:',
      );
      console.warn('  gh extension upgrade stack');
    }
    return;
  }

  console.log(`Installing ${EXTENSION_REPO} extension...`);
  try {
    execFileSync('gh', ['extension', 'install', EXTENSION_REPO], {
      stdio: ['ignore', 'inherit', 'inherit'],
      env,
    });
    console.log('✅ gh-stack installed');
  } catch {
    console.warn(
      `⚠️  Could not install ${EXTENSION_REPO} (offline or not logged into gh). Log in with \`gh auth login\`, then run \`./bs gh-stack\` or:`,
    );
    console.warn(`  gh extension install ${EXTENSION_REPO}`);
  }
}
