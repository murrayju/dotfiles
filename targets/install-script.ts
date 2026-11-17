import fs from 'fs-extra';
import * as path from 'path';
import { spawn } from 'child_process';
import * as os from 'os';

const HOME_DIR: string = os.homedir();
const MISE_SHIMS: string = path.join(HOME_DIR, '.local/share/mise/shims');

/**
 * Run a `curl … | <shell>` installer without letting it ask anything.
 *
 * Many upstream installers are interactive: they ask whether to install or
 * reinstall, whether to edit your shell profile, or whether to start the tool.
 * Each of those prompts is guarded by a `/dev/tty` check, so running the
 * installer in its own session (`detached`, i.e. no controlling terminal)
 * makes it take its default action instead of prompting. stdin is closed as
 * well, so it cannot read from the user's terminal either. PATH gets the mise
 * shims first, so node/npm come from mise and the installer never offers to
 * install Node itself.
 *
 * `shellCommand` is the full pipeline, for example
 * `curl -fsSL https://example.com/install.sh | bash`. The interpreter is up to
 * the caller because some installers use bash-only syntax. The pipeline runs
 * under `bash -o pipefail`, so a failed `curl` (offline, 404) is not masked by
 * an empty stdin that makes the inner shell exit 0.
 *
 * Resolves with the installer's exit code, or `null` when a signal killed it.
 */
export function runInstaller(
  shellCommand: string,
  extraEnv: NodeJS.ProcessEnv = {},
): Promise<number | null> {
  const env: NodeJS.ProcessEnv = { ...process.env, ...extraEnv };
  if (fs.existsSync(MISE_SHIMS)) {
    env.PATH = `${MISE_SHIMS}:${env.PATH ?? ''}`;
  }

  return new Promise((resolve, reject) => {
    const child = spawn('/bin/bash', ['-o', 'pipefail', '-c', shellCommand], {
      stdio: ['ignore', 'inherit', 'inherit'],
      env,
      detached: true,
    });

    // A detached child is its own process-group leader, so signal the whole
    // group: `child.kill` alone would reach only the shell and leave curl and
    // the inner shell running. The group may already be gone, so ignore ESRCH.
    const forward = (signal: NodeJS.Signals) => {
      if (child.pid === undefined) {
        return;
      }
      try {
        process.kill(-child.pid, signal);
      } catch {
        // The group already exited.
      }
    };
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
