import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
const BRANCH = 'main';

type Checkout = { name: string; directory: string; repository: string };

/** Run git and return its trimmed stdout. */
function gitOutput(args: string[]): string {
  return execFileSync('git', args, {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  }).trim();
}

/** True when git config has a value for `key`. */
function gitConfigHas(key: string): boolean {
  try {
    return gitOutput(['config', '--get', key]) !== '';
  } catch {
    // git exits 1 when the key is not set.
    return false;
  }
}

/**
 * An environment that stops git from asking anything.
 *
 * The clone uses https, but the pull follows the remote that the clone
 * records, which is usually ssh. A missing key or an unknown host would then
 * wait on a passphrase or host-key prompt for as long as the bootstrap runs.
 * A user-configured ssh command is left alone: it may select a specific key.
 */
function gitEnvironment(): NodeJS.ProcessEnv {
  const env: NodeJS.ProcessEnv = {
    ...process.env,
    GIT_TERMINAL_PROMPT: '0',
  };
  if (!env.GIT_SSH_COMMAND && !gitConfigHas('core.sshCommand')) {
    env.GIT_SSH_COMMAND = 'ssh -o BatchMode=yes';
  }
  return env;
}

/**
 * The repository a remote URL points at, as `host/owner/repo`.
 *
 * This makes the ssh and https forms of one repository compare equal.
 */
function repositoryKey(remoteUrl: string): string {
  const trimmed: string = remoteUrl
    .trim()
    .replace(/\/+$/, '')
    .replace(/\.git$/, '');
  // scp-like syntax, for example git@github.com:owner/repo.
  const scpLike = /^[^@/]+@([^:/]+):(.+)$/.exec(trimmed);
  let parsed: URL | undefined;
  try {
    parsed = new URL(scpLike ? `ssh://${scpLike[1]}/${scpLike[2]}` : trimmed);
  } catch {
    parsed = undefined;
  }
  if (!parsed) {
    return trimmed.toLowerCase();
  }
  return `${parsed.hostname}${parsed.pathname}`.toLowerCase();
}

/** Check that `origin` points to the expected repository. */
function isExpectedClone(dir: string, repository: string): boolean {
  if (!fs.existsSync(path.join(dir, '.git'))) {
    return false;
  }
  try {
    return (
      repositoryKey(gitOutput(['-C', dir, 'remote', 'get-url', 'origin'])) ===
      repositoryKey(repository)
    );
  } catch {
    return false;
  }
}

/** The checked-out branch, or undefined for a detached HEAD. */
function currentBranch(dir: string): string | undefined {
  try {
    return gitOutput(['-C', dir, 'symbolic-ref', '--short', 'HEAD']);
  } catch {
    return undefined;
  }
}

function isEmptyDir(dir: string): boolean {
  return fs.statSync(dir).isDirectory() && fs.readdirSync(dir).length === 0;
}

function cloneCheckout({ name, directory, repository }: Checkout): void {
  console.log(`Cloning ${repository} into ${directory}...`);
  try {
    fs.ensureDirSync(path.dirname(directory));
    execFileSync('git', ['clone', '--branch', BRANCH, repository, directory], {
      stdio: 'inherit',
      env: gitEnvironment(),
    });
    console.log(`✅ ${name} cloned (${directory})`);
  } catch {
    console.warn(`⚠️  Could not clone ${repository}. Clone it by hand with:`);
    console.warn(`  git clone --branch ${BRANCH} ${repository} ${directory}`);
  }
}

function updateCheckout({ name, directory }: Checkout): void {
  const branch = currentBranch(directory);
  if (branch !== BRANCH) {
    console.warn(
      `⚠️  ${directory} is on ${branch ?? 'a detached HEAD'}, not ${BRANCH}.`,
    );
    console.warn('  It was left alone. Check out the branch to get updates.');
    return;
  }
  console.log(`Updating ${name.toLowerCase()} in ${directory}...`);
  try {
    execFileSync(
      'git',
      ['-C', directory, 'pull', '--ff-only', 'origin', BRANCH],
      {
        stdio: 'inherit',
        env: gitEnvironment(),
      },
    );
    console.log(`✅ ${name} up to date (${directory})`);
  } catch {
    console.warn(
      `⚠️  Could not update ${directory} (offline, or it cannot fast-forward).`,
    );
    console.warn(
      `  Update it by hand with: git -C ${directory} pull --ff-only`,
    );
  }
}

/** Clone or fast-forward main. Do not replace an unrelated directory. */
export default function syncGitCheckout(checkout: Checkout): void {
  const { directory, repository } = checkout;
  if (!fs.existsSync(directory) || isEmptyDir(directory)) {
    cloneCheckout(checkout);
    return;
  }
  if (!isExpectedClone(directory, repository)) {
    console.warn(
      `⚠️  ${directory} exists and is not a clone of ${repository}.`,
    );
    console.warn(
      '  It was left alone. Move it aside to let the bootstrap manage it.',
    );
    return;
  }
  updateCheckout(checkout);
}
