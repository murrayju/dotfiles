import * as os from 'os';
import * as path from 'path';
import syncGitCheckout from './git-checkout.ts';

export default async function installSkills(): Promise<void> {
  syncGitCheckout({
    name: 'Skills',
    directory: path.join(os.homedir(), '.agents', 'skills'),
    repository: 'https://github.com/murrayju/skills.git',
  });
}
