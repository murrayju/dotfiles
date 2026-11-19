import fs from 'fs-extra';
import * as path from 'path';
import * as os from 'os';
import { isDeepStrictEqual } from 'util';

const HOME_DIR: string = os.homedir();
const AGENT_DIR: string =
  process.env.PI_CODING_AGENT_DIR ?? path.join(HOME_DIR, '.pi', 'agent');
const MODELS_FILE: string = path.join(AGENT_DIR, 'models.json');
const PROVIDER_ID: string = 'anthropic-mythos';
const API_KEY_VARIABLE: string = 'MYTHOS_API_KEY';

/**
 * The model uses the Anthropic API and its own key.
 *
 * Pi applies `apiKey` to every model of a provider. The built-in `anthropic`
 * provider would give this key to all of its Claude models. A separate provider
 * ID keeps the key and the single model isolated. The model fields match
 * `claude-fable-5-2`.
 */
const MYTHOS_PROVIDER: Record<string, unknown> = {
  name: 'Anthropic (Mythos)',
  baseUrl: 'https://api.anthropic.com',
  api: 'anthropic-messages',
  apiKey: `$${API_KEY_VARIABLE}`,
  models: [
    {
      id: 'claude-mythos-5-2',
      name: 'Claude Mythos 5.2',
      input: ['text', 'image'],
      reasoning: true,
      contextWindow: 1_000_000,
      maxTokens: 128_000,
      cost: {
        input: 8,
        output: 40,
        cacheRead: 0.2,
        cacheWrite: 10,
      },
      thinkingLevelMap: {
        off: null,
        minimal: null,
        low: 'low',
        medium: 'medium',
        high: 'high',
        xhigh: 'xhigh',
        max: 'max',
      },
      compat: {
        forceAdaptiveThinking: true,
      },
    },
  ],
};

function readJsonObject(file: string, label: string): Record<string, unknown> {
  const value: unknown = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    throw new Error(`${label} must be a JSON object: ${file}`);
  }
  return value as Record<string, unknown>;
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

/**
 * Add the `claude-mythos-5-2` model to Pi's catalog.
 *
 * The model gets a dedicated provider, so the key in `$MYTHOS_API_KEY` reaches
 * only this model. The bootstrap runs this step after `cn refresh`, because
 * that command rewrites `models.json`. Every other provider stays as it is.
 */
export default async function configurePiMythos(): Promise<void> {
  if (!fs.existsSync(MODELS_FILE)) {
    console.log(
      'Skipping the Anthropic Mythos model: Pi has no models.json yet. Run `cn configure pi` first.',
    );
    return;
  }
  const stats = fs.lstatSync(MODELS_FILE);
  if (!stats.isFile()) {
    throw new Error(`Refusing to change a non-regular file: ${MODELS_FILE}`);
  }

  const currentText: string = fs.readFileSync(MODELS_FILE, 'utf8');
  const config = readJsonObject(MODELS_FILE, 'pi models');
  const providers = config.providers;
  if (
    typeof providers !== 'object' ||
    providers === null ||
    Array.isArray(providers)
  ) {
    throw new Error(`pi models has no providers object: ${MODELS_FILE}`);
  }
  const providerList = providers as Record<string, unknown>;

  if (isDeepStrictEqual(providerList[PROVIDER_ID], MYTHOS_PROVIDER)) {
    console.log(
      `✅ Anthropic Mythos model is already configured (${MODELS_FILE})`,
    );
  } else {
    providerList[PROVIDER_ID] = MYTHOS_PROVIDER;
    const endsWithNewline: boolean = currentText.endsWith('\n');
    const nextText: string = `${JSON.stringify(config, null, 2)}${endsWithNewline ? '\n' : ''}`;
    replacePrivateFile(MODELS_FILE, nextText, stats.mode & 0o777);
    console.log(`✅ Anthropic Mythos model configured (${MODELS_FILE})`);
  }

  if ((process.env[API_KEY_VARIABLE] ?? '').trim() === '') {
    console.warn(
      `⚠️  ${API_KEY_VARIABLE} is not set. The model stays unavailable until you set it.`,
    );
  }
}
