import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import { concentrateConfigDir, findConcentrate } from './concentrate.ts';
import { readSavedKey } from './concentrate-key.ts';
import { findPi, withPiOnPath } from './pi.ts';

const RECEIPT_FILE: string = path.join(
  concentrateConfigDir(),
  'tool-setups',
  'pi',
  'restore.json',
);

/**
 * Return true when cn has an active Pi setup.
 *
 * This follows `hasNativeSetup` in cn: the restore record is active only when
 * it has version 1 and `active` is true.
 */
export function piIsConfigured(): boolean {
  try {
    const record: unknown = JSON.parse(fs.readFileSync(RECEIPT_FILE, 'utf8'));
    const fields = record as Record<string, unknown>;
    return fields.version === 1 && fields.active === true;
  } catch {
    // There is no record, or it is not readable JSON. Either way cn has no
    // Pi setup.
    return false;
  }
}

/**
 * Connect Pi to Concentrate with `cn configure pi`.
 *
 * `cn configure pi` needs two things: a key that cn saved, and a `pi` command
 * on `PATH`. This process does not load the shell profile, so the step puts the
 * directory that holds the pi launcher first on the `PATH` of the command.
 *
 * The step skips when Pi is already connected, because `cn refresh` (in the
 * prune step) updates an existing setup. `cn configure pi` refuses a settings
 * file that was edited after the last configure, so a repeated run would fail
 * for no gain.
 *
 * Run this before `pi-settings`, because `cn configure pi` writes its own
 * default model, and `pi-settings` then applies the managed one. Run it after
 * the key step, because cn needs a saved key for a permanent setup.
 */
export default async function configureConcentratePi(): Promise<void> {
  const cn = findConcentrate();
  if (!cn) {
    console.log('Skipping the Concentrate Pi setup: cn is not installed');
    return;
  }
  if (!findPi()) {
    console.log('Skipping the Concentrate Pi setup: pi is not installed');
    return;
  }
  if (piIsConfigured()) {
    console.log('✅ Pi is already connected to Concentrate');
    return;
  }
  if (!readSavedKey()) {
    console.log(
      'Skipping the Concentrate Pi setup: cn has no saved key. Run `cn key`, then `cn configure pi`.',
    );
    return;
  }

  console.log('Connecting Pi to Concentrate...');
  try {
    execFileSync(cn, ['configure', 'pi'], {
      stdio: 'inherit',
      env: withPiOnPath(process.env),
    });
  } catch {
    console.warn(
      '⚠️  cn could not configure Pi. Run `cn configure pi` to see why.',
    );
    return;
  }

  if (piIsConfigured()) {
    console.log('✅ Pi is connected to Concentrate');
    return;
  }
  console.warn('⚠️  cn finished, but left no Pi setup record.');
}
