import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import { createInterface } from 'node:readline/promises';
import { concentrateConfigDir, findConcentrate } from './concentrate.ts';

// cn saves the key here with mode 600. The dotfiles never copy or track it.
const CREDENTIALS_FILE_NAME: string = 'credentials.json';

/** Return the key that cn has saved, if there is one. */
function readSavedKey(): string | undefined {
  try {
    const file: string = path.join(
      concentrateConfigDir(),
      CREDENTIALS_FILE_NAME,
    );
    const saved: unknown = JSON.parse(fs.readFileSync(file, 'utf8'));
    const key = (saved as Record<string, unknown>).api_key;
    if (typeof key === 'string' && key.trim() !== '') {
      return key.trim();
    }
  } catch {
    // No file yet, or it is not readable JSON. Either way there is no key.
  }
  return undefined;
}

/** Ask a yes/no question on the terminal. An empty answer means yes. */
async function confirm(question: string): Promise<boolean> {
  const terminal = createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  // Ctrl+C stops the bootstrap, as it does everywhere else. Only end of input
  // is treated as a skip, so Ctrl+D and a closed terminal do not abort a run.
  terminal.on('SIGINT', () => {
    terminal.close();
    process.stdout.write('\n');
    process.exit(130);
  });
  try {
    const answer = (await terminal.question(question)).trim().toLowerCase();
    return answer === '' || answer === 'y' || answer === 'yes';
  } catch {
    // End of input (Ctrl+D) or a closed terminal. Treat it as "no".
    process.stdout.write('\n');
    return false;
  } finally {
    terminal.close();
  }
}

/**
 * Save the Concentrate AI API key when cn has none yet.
 *
 * `cn key` asks for the key with a hidden prompt, checks it against the API,
 * and writes it to the cn config directory with mode 600. The key never enters
 * this repository or this process, so it cannot leak through logs or argv.
 *
 * The step asks before it acts, and it skips when the key is already saved,
 * when cn reads the key from `CONCENTRATE_API_KEY`, and when there is no
 * terminal to ask on. A non-interactive bootstrap therefore never hangs.
 */
export default async function configureConcentrateKey(): Promise<void> {
  if (readSavedKey()) {
    console.log('✅ Concentrate AI API key already saved');
    return;
  }

  const cn = findConcentrate();
  if (!cn) {
    console.log('Skipping the Concentrate AI API key: cn is not installed');
    return;
  }

  if ((process.env.CONCENTRATE_API_KEY ?? '').trim() !== '') {
    console.log('✅ Concentrate AI API key comes from CONCENTRATE_API_KEY');
    return;
  }

  if (!process.stdin.isTTY || !process.stdout.isTTY) {
    console.log(
      'Skipping the Concentrate AI API key: no terminal to ask on. Run `cn key` later.',
    );
    return;
  }

  if (!(await confirm('Save a Concentrate AI API key now? [Y/n] '))) {
    console.log('Skipped the Concentrate AI API key. Run `cn key` later.');
    return;
  }

  try {
    // cn asks for the key, checks it against the API, then saves it.
    execFileSync(cn, ['key'], { stdio: 'inherit' });
  } catch (error) {
    const failure = error as { status?: number | null; signal?: string | null };
    if (failure.status === 130 || failure.signal === 'SIGINT') {
      process.exit(130);
    }
    console.warn(
      '⚠️  No Concentrate AI API key was saved. Run `cn key` to try again.',
    );
  }
}
