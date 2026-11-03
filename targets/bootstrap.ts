import fs from 'fs-extra';
import * as path from 'path';
import { execSync } from 'child_process';
import * as os from 'os';
import { fileURLToPath } from 'url';
import { ensureBrewfileInstalled, ensureBrewInstalled } from 'build-strap';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DOTFILES_DIR: string = path.join(path.dirname(__dirname), 'dotfiles');
const HOME_DIR: string = os.homedir();
const BACKUP_DIR: string = path.join(HOME_DIR, '.dotfiles_backup');
// The mise.run installer puts mise here.
const MISE_BIN: string = path.join(HOME_DIR, '.local/bin/mise');

interface DiffResult {
  diffLines: number;
  error?: boolean;
}

function getDiffSummary(file1: string, file2: string): DiffResult {
  try {
    const content1 = fs.readFileSync(file1, 'utf8').split('\n');
    const content2 = fs.readFileSync(file2, 'utf8').split('\n');

    let diffLines = 0;
    const maxLength = Math.max(content1.length, content2.length);

    for (let i = 0; i < maxLength; i++) {
      const line1 = content1[i] || '';
      const line2 = content2[i] || '';
      if (line1 !== line2) {
        diffLines++;
      }
    }

    return { diffLines };
  } catch (error) {
    return { diffLines: -1, error: true };
  }
}

function filesAreEqual(file1: string, file2: string): boolean {
  try {
    const content1 = fs.readFileSync(file1, 'utf8');
    const content2 = fs.readFileSync(file2, 'utf8');
    return content1 === content2;
  } catch (error) {
    return false;
  }
}

async function symlinkDirContents(
  sourceDir: string,
  targetDir: string,
  prefix = '',
) {
  const items = await fs.readdir(sourceDir);
  await fs.ensureDir(targetDir);
  for (const item of items) {
    const sourcePath = path.join(sourceDir, item);
    const sourceStats = fs.lstatSync(sourcePath);
    const name = path.join(prefix, item);
    if (sourceStats.isDirectory()) {
      await symlinkDirContents(sourcePath, path.join(targetDir, item), name);
      console.log(`  ✓ ${name} (directory contents linked)`);
      continue;
    }
    const targetPath = path.join(targetDir, item);
    if (fs.existsSync(targetPath)) {
      const targetStats = await fs.lstat(targetPath);
      if (targetStats.isSymbolicLink()) {
        const linkTarget = await fs.readlink(targetPath);
        if (path.resolve(linkTarget) === path.resolve(sourcePath)) {
          console.log(`  ✓ ${name} (already linked)`);
          continue;
        } else {
          await fs.unlink(targetPath);
          console.log(`  ⚠️  ${name} - removed old symlink to ${linkTarget}`);
        }
      } else {
        if (filesAreEqual(sourcePath, targetPath)) {
          // Files are identical, just remove and link
          await fs.unlink(targetPath);
        } else {
          // Backup existing item and replace with link
          const diffResult = getDiffSummary(sourcePath, targetPath);
          await fs.ensureDir(path.join(BACKUP_DIR, prefix));
          let backupPath = path.join(BACKUP_DIR, prefix, item);
          if (await fs.exists(backupPath)) {
            backupPath = path.join(BACKUP_DIR, prefix, `${item}-${Date.now()}`);
          }
          try {
            await fs.move(targetPath, backupPath);
          } catch (error) {
            console.error(`Failed to backup ${targetPath} to ${backupPath}`);
            throw error;
          }
          console.log(
            `  ⚠️  ${name} (backed up, ${diffResult.diffLines} differing lines)`,
          );
        }
      }
    }
    await fs.symlink(sourcePath, targetPath);
    console.log(`  ✓ ${name}`);
  }
}

async function symlinkDotfiles() {
  console.log('\nCreating symlinks for dotfiles...');

  await symlinkDirContents(DOTFILES_DIR, HOME_DIR);
}

function installOhMyZsh(): void {
  const zshDir = path.join(HOME_DIR, '.oh-my-zsh');
  if (!fs.existsSync(zshDir)) {
    console.log('Installing Oh My Zsh...');
    try {
      execSync(
        'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended',
        { stdio: 'inherit' },
      );
    } catch (error) {
      console.log('Oh My Zsh installation failed or was skipped');
    }
  }
}

function installPowerlevel10k(): void {
  const p10kDir = path.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k');
  if (!fs.existsSync(p10kDir)) {
    console.log('Installing Powerlevel10k theme...');
    try {
      execSync(
        'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k',
        { stdio: 'inherit' },
      );
    } catch (error) {
      console.log('Powerlevel10k installation failed');
    }
  }
}

function installTmuxPluginManager(): void {
  const tpmDir = path.join(HOME_DIR, '.tmux/plugins/tpm');
  if (!fs.existsSync(tpmDir)) {
    console.log('Installing Tmux Plugin Manager...');
    try {
      execSync(
        'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm',
        { stdio: 'inherit' },
      );
    } catch (error) {
      console.log('TPM installation failed');
    }
  }
}

function installMiseTools(): void {
  if (!fs.existsSync(MISE_BIN)) {
    console.log('Installing mise...');
    execSync('curl -fsSL https://mise.run | sh', { stdio: 'inherit' });
  }
  // Install the tools in the global config (~/.config/mise/config.toml).
  execSync(`"${MISE_BIN}" install`, { stdio: 'inherit', cwd: HOME_DIR });
}

export default async function main() {
  console.log('🚀 Starting dotfiles bootstrap...');

  // Create symlinks for dotfiles
  await symlinkDotfiles();

  // Install additional tools
  installOhMyZsh();
  installPowerlevel10k();
  installTmuxPluginManager();

  console.log('\n🍺 Installing Homebrew and Brewfile...');
  await ensureBrewInstalled();
  await ensureBrewfileInstalled(path.join(__dirname, '..', 'Brewfile'));

  console.log('\n🧰 Installing mise and its tools...');
  installMiseTools();

  console.log('\n✅ Bootstrap completed!');
  console.log('\nNext steps:');
  console.log('1. Run "source ~/.zshrc" to reload your shell');
}
