import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import * as os from 'os';

const HOME_DIR: string = os.homedir();
// pi discovers skills in ~/.agents/skills. Other tools also install skills
// there, so they live next to this clone rather than in their own directory.
const SKILLS_DIR: string = path.join(HOME_DIR, '.agents', 'skills');
const SKILLS_REPO_URL: string = 'https://github.com/murrayju/skills.git';
const SKILLS_BRANCH: string = 'main';

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

/** True when `dir` is a clone of the skills repository. */
function isSkillsClone(dir: string): boolean {
  if (!fs.existsSync(path.join(dir, '.git'))) {
    return false;
  }
  try {
    return (
      repositoryKey(gitOutput(['-C', dir, 'remote', 'get-url', 'origin'])) ===
      repositoryKey(SKILLS_REPO_URL)
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

/** Clone the skills repository into the skills directory. */
function cloneSkills(): void {
  console.log(`Cloning ${SKILLS_REPO_URL} into ${SKILLS_DIR}...`);
  fs.ensureDirSync(path.dirname(SKILLS_DIR));
  try {
    execFileSync(
      'git',
      ['clone', '--branch', SKILLS_BRANCH, SKILLS_REPO_URL, SKILLS_DIR],
      { stdio: 'inherit', env: gitEnvironment() },
    );
    console.log(`✅ Skills cloned (${SKILLS_DIR})`);
  } catch {
    console.warn(
      `⚠️  Could not clone ${SKILLS_REPO_URL}. Clone it by hand with:`,
    );
    console.warn(
      `  git clone --branch ${SKILLS_BRANCH} ${SKILLS_REPO_URL} ${SKILLS_DIR}`,
    );
  }
}

/**
 * Fast-forward the skills clone to latest main.
 *
 * A pull that cannot fast-forward (local commits, or local changes in the
 * way) fails, and losing the rest of the bootstrap over that is not worth it,
 * so this only warns.
 */
function updateSkills(): void {
  const branch = currentBranch(SKILLS_DIR);
  if (branch !== SKILLS_BRANCH) {
    console.warn(
      `⚠️  ${SKILLS_DIR} is on ${branch ?? 'a detached HEAD'}, not ${SKILLS_BRANCH}.`,
    );
    console.warn('  It was left alone. Check out the branch to get updates.');
    return;
  }
  console.log(`Updating skills in ${SKILLS_DIR}...`);
  try {
    execFileSync(
      'git',
      ['-C', SKILLS_DIR, 'pull', '--ff-only', 'origin', SKILLS_BRANCH],
      { stdio: 'inherit', env: gitEnvironment() },
    );
    console.log(`✅ Skills up to date (${SKILLS_DIR})`);
  } catch {
    console.warn(
      `⚠️  Could not update ${SKILLS_DIR} (offline, or it cannot fast-forward).`,
    );
    console.warn(
      `  Update it by hand with: git -C ${SKILLS_DIR} pull --ff-only`,
    );
  }
}

/**
 * Keep the skills clone at ~/.agents/skills, and pull latest main from it.
 *
 * A directory that is not a clone of the skills repository is left untouched:
 * other tools install skills there too, and deleting them is not this step's
 * job. That also means those tools can claim the directory before the first
 * bootstrap, and the bootstrap then only warns.
 */
export default async function installSkills(): Promise<void> {
  if (!fs.existsSync(SKILLS_DIR) || isEmptyDir(SKILLS_DIR)) {
    cloneSkills();
    return;
  }
  if (!isSkillsClone(SKILLS_DIR)) {
    console.warn(
      `⚠️  ${SKILLS_DIR} exists and is not a clone of ${SKILLS_REPO_URL}.`,
    );
    console.warn(
      '  It was left alone. Move it aside to let the bootstrap manage it.',
    );
    return;
  }
  updateSkills();
}
