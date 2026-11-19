import * as os from 'os';
import * as path from 'path';
import syncGitCheckout from './git-checkout.ts';

export default async function installPiHerdrSubagents(): Promise<void> {
  const agentDir =
    process.env.PI_CODING_AGENT_DIR ?? path.join(os.homedir(), '.pi', 'agent');
  syncGitCheckout({
    name: 'Pi Herdr subagents',
    directory: path.join(agentDir, 'extensions', 'herdr-subagents'),
    repository: 'https://github.com/murrayju/pi-herdr-subagents.git',
  });
}
