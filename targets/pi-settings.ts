import fs from 'fs-extra';
import * as path from 'path';
import { execFileSync } from 'child_process';
import * as os from 'os';
import { isDeepStrictEqual } from 'util';
import { fileURLToPath } from 'url';
import { concentrateConfigDir, findConcentrate } from './concentrate.ts';
import { withPiOnPath } from './pi.ts';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const HOME_DIR: string = os.homedir();
// The managed preferences, tracked in the repository. pi's own settings file
// also holds version stamps and anything changed inside pi, so it is merged,
// never replaced.
const SETTINGS_SOURCE: string = path.join(
  __dirname,
  '..',
  'pi',
  'settings.json',
);
const AGENT_DIR: string =
  process.env.PI_CODING_AGENT_DIR ?? path.join(HOME_DIR, '.pi', 'agent');
const SETTINGS_FILE: string = path.join(AGENT_DIR, 'settings.json');
const CONCENTRATE_CONFIG_DIR: string = concentrateConfigDir();
const RECEIPT_FILE: string = path.join(
  CONCENTRATE_CONFIG_DIR,
  'tool-setups',
  'pi',
  'restore.json',
);
const RECEIPT_LOCK: string = path.join(
  CONCENTRATE_CONFIG_DIR,
  'tool-setups',
  'pi',
  '.lock',
);
// The settings that `cn configure pi` writes. A different value makes cn treat
// the settings file as hand-edited and refuse to refresh Pi.
const CONCENTRATE_TRACKED_KEYS: string[][] = [
  ['defaultProvider'],
  ['defaultModel'],
];

function readJsonObject(file: string, label: string): Record<string, unknown> {
  const value: unknown = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    throw new Error(`${label} must be a JSON object: ${file}`);
  }
  return value as Record<string, unknown>;
}

/** The source of a package entry, which may be a string or an object. */
function packageSource(entry: unknown): string | undefined {
  if (typeof entry === 'string') {
    return entry;
  }
  if (entry && typeof entry === 'object' && !Array.isArray(entry)) {
    const source = (entry as Record<string, unknown>).source;
    if (typeof source === 'string') {
      return source;
    }
  }
  return undefined;
}

/**
 * Add managed packages that are missing. Packages installed by other means stay
 * in the list: this step installs preferences, it does not uninstall anything.
 */
function mergePackages(current: unknown, managed: unknown): unknown[] {
  const merged: unknown[] = Array.isArray(current) ? [...current] : [];
  const knownSources = new Set(merged.map(packageSource).filter(Boolean));
  for (const entry of Array.isArray(managed) ? managed : []) {
    const source = packageSource(entry);
    if (source === undefined) {
      throw new Error(`Not a pi package source: ${JSON.stringify(entry)}`);
    }
    if (knownSources.has(source)) {
      continue;
    }
    merged.push(entry);
    knownSources.add(source);
  }
  return merged;
}

function replacePrivateFile(file: string, text: string, mode: number): void {
  fs.ensureDirSync(path.dirname(file));
  const temporaryFile = `${file}.${process.pid}.tmp`;
  try {
    fs.writeFileSync(temporaryFile, text, { mode });
    fs.renameSync(temporaryFile, file);
  } finally {
    fs.rmSync(temporaryFile, { force: true });
  }
}

/** Merge the managed keys into pi's settings file. Return the text written. */
function applyManagedSettings(
  managed: Record<string, unknown>,
): string | undefined {
  if (fs.existsSync(SETTINGS_FILE)) {
    const stats = fs.lstatSync(SETTINGS_FILE);
    if (!stats.isFile() || stats.isSymbolicLink()) {
      throw new Error(
        `Refusing to change a non-regular file: ${SETTINGS_FILE}`,
      );
    }
  }
  const currentText: string = fs.existsSync(SETTINGS_FILE)
    ? fs.readFileSync(SETTINGS_FILE, 'utf8')
    : '';
  const current: Record<string, unknown> =
    currentText.trim() === ''
      ? {}
      : readJsonObject(SETTINGS_FILE, 'pi settings');

  // Keep every key that this step does not manage, in its current order, and
  // append the managed keys that are new.
  const next: Record<string, unknown> = { ...current };
  for (const [key, value] of Object.entries(managed)) {
    next[key] = key === 'packages' ? mergePackages(current[key], value) : value;
  }

  if (isDeepStrictEqual(next, current)) {
    console.log(`✅ pi settings already up to date (${SETTINGS_FILE})`);
    return undefined;
  }

  // pi writes without a trailing newline. Follow the file that is already there.
  const endsWithNewline: boolean = currentText.endsWith('\n');
  const nextText: string = `${JSON.stringify(next, null, 2)}${endsWithNewline ? '\n' : ''}`;
  const mode: number = fs.existsSync(SETTINGS_FILE)
    ? fs.statSync(SETTINGS_FILE).mode & 0o777
    : 0o600;
  replacePrivateFile(SETTINGS_FILE, nextText, mode);
  console.log(`✅ pi settings updated (${SETTINGS_FILE})`);
  return nextText;
}

/**
 * Keep cn's default Pi model the same as the managed one, so `cn refresh`
 * writes this value back instead of replacing it with cn's own default.
 */
function alignConcentrateDefaultModel(defaultModel: string): void {
  const cn = findConcentrate();
  if (!cn) {
    return;
  }
  const preferencesFile = path.join(CONCENTRATE_CONFIG_DIR, 'config.json');
  if (fs.existsSync(preferencesFile)) {
    const preferences = readJsonObject(preferencesFile, 'cn config');
    const models = preferences.models;
    if (
      models &&
      typeof models === 'object' &&
      (models as Record<string, unknown>).pi === defaultModel
    ) {
      return;
    }
  } else {
    // cn starts on its built-in default, which is a different model.
  }

  console.log(`Setting cn's default Pi model to ${defaultModel}...`);
  try {
    // cn reconfigures Pi after it saves the model, and it finds `pi` on PATH.
    execFileSync(cn, ['model', 'pi', defaultModel], {
      stdio: 'inherit',
      env: withPiOnPath(process.env),
    });
  } catch {
    console.warn(
      "⚠️  Could not save cn's default model. `cn refresh` will keep using its own default.",
    );
  }
}

/**
 * Record the managed default model in cn's restore record.
 *
 * `cn refresh` refuses a settings file whose tracked values differ from the
 * record it wrote, which is how it protects hand edits. This step writes those
 * values, so the record must follow, or every later refresh skips Pi.
 */
function syncConcentrateReceipt(managed: Record<string, unknown>): void {
  if (!fs.existsSync(RECEIPT_FILE)) {
    return;
  }
  if (fs.existsSync(RECEIPT_LOCK)) {
    throw new Error(
      `cn is configuring Pi (${RECEIPT_LOCK}). Wait for it to finish, then run the command again.`,
    );
  }
  const stats = fs.lstatSync(RECEIPT_FILE);
  if (!stats.isFile() || stats.isSymbolicLink()) {
    throw new Error(`Refusing to change a non-regular file: ${RECEIPT_FILE}`);
  }

  const receipt = readJsonObject(RECEIPT_FILE, 'cn restore record');
  if (receipt.version !== 1 || receipt.active !== true) {
    return;
  }
  if (!Array.isArray(receipt.files)) {
    throw new Error(`The cn restore record has no file list: ${RECEIPT_FILE}`);
  }
  const snapshot = receipt.files.find(
    (item: unknown): item is Record<string, unknown> =>
      typeof item === 'object' &&
      item !== null &&
      (item as Record<string, unknown>).file === SETTINGS_FILE,
  );
  if (!snapshot || snapshot.format !== 'json') {
    return;
  }
  if (!Array.isArray(snapshot.changes) || snapshot.changes.length === 0) {
    return;
  }

  // Only the values this step owns may differ from the record. Any other
  // tracked setting is a real edit, and cn must keep seeing it as one.
  const live = readJsonObject(SETTINGS_FILE, 'pi settings');
  for (const change of snapshot.changes) {
    const key = (change as Record<string, unknown>).key;
    const isManaged = CONCENTRATE_TRACKED_KEYS.some(
      (tracked) => JSON.stringify(tracked) === JSON.stringify(key),
    );
    if (!isManaged) {
      console.warn(
        `⚠️  cn also tracks ${JSON.stringify(key)} in ${SETTINGS_FILE}, which this step does not manage. It was left alone, so \`cn refresh\` may skip Pi.`,
      );
      return;
    }
    const [name] = key as string[];
    if (!isDeepStrictEqual(live[name], managed[name])) {
      throw new Error(
        `${SETTINGS_FILE}: ${name} is not the managed value, so the cn restore record was left alone. Run cn reset pi, then cn configure pi.`,
      );
    }
  }

  const writtenBefore = JSON.parse(String(snapshot.written)) as Record<
    string,
    unknown
  >;
  const changed = snapshot.changes.some((change) => {
    const [name] = (change as Record<string, unknown>).key as string[];
    return !isDeepStrictEqual(writtenBefore[name], live[name]);
  });
  if (!changed) {
    return;
  }

  for (const change of snapshot.changes) {
    const entry = change as Record<string, unknown>;
    const [name] = entry.key as string[];
    entry.value = live[name];
  }
  snapshot.written = `${JSON.stringify(live, null, 2)}\n`;
  // cn may have started a configuration while this step was running.
  if (fs.existsSync(RECEIPT_LOCK)) {
    throw new Error(
      `cn started configuring Pi (${RECEIPT_LOCK}). Run the command again when it finishes.`,
    );
  }
  const receiptMode = fs.statSync(RECEIPT_FILE).mode & 0o777;
  replacePrivateFile(
    RECEIPT_FILE,
    `${JSON.stringify(receipt, null, 2)}\n`,
    receiptMode,
  );
  console.log(`Recorded the managed default model in ${RECEIPT_FILE}`);
}

/**
 * Apply the tracked pi preferences to pi's settings file.
 *
 * Only the keys in pi/settings.json are written. Version stamps, the theme, and
 * anything else that pi keeps there are left as they are.
 */
export default async function installPiSettings(): Promise<void> {
  const managed = readJsonObject(SETTINGS_SOURCE, 'managed pi settings');

  const defaultModel = managed.defaultModel;
  if (typeof defaultModel === 'string' && defaultModel !== '') {
    // Set cn's default model first. cn reconfigures Pi when it saves the model,
    // and `cn configure pi` refuses a settings file that differs from its own
    // record. Writing the settings first would therefore make cn warn.
    alignConcentrateDefaultModel(defaultModel);
  }
  applyManagedSettings(managed);
  if (typeof defaultModel === 'string' && defaultModel !== '') {
    syncConcentrateReceipt(managed);
  }
}
