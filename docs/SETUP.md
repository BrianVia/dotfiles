# Setup Instructions for New Machine

Complete guide to bootstrap a brand new macOS or Linux machine from zero.

## Prerequisites

A blank machine with internet access. That's it.

| | macOS | Linux (Ubuntu/Debian) |
|---|---|---|
| **Git** | Comes with Xcode CLI tools | `sudo apt install git` |
| **Curl** | Pre-installed | `sudo apt install curl` |
| **Ansible** | `brew install ansible` | `sudo apt install ansible` |

## Step 1: System Basics

### macOS

```bash
# Xcode command line tools (includes git, make, clang)
xcode-select --install

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ansible (for SSH key decryption)
brew install ansible
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y git curl software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible
```

## Step 2: Clone Dotfiles

```bash
mkdir -p ~/Development/Personal
git clone git@github.com:BrianVia/dotfiles.git ~/Development/Personal/dotfiles
cd ~/Development/Personal/dotfiles
```

> **No SSH key yet?** The repo is public — use HTTPS instead:
> `git clone https://github.com/BrianVia/dotfiles.git ~/Development/Personal/dotfiles`

## Step 3: Run the Installer

```bash
./install.sh
```

You'll be prompted for the **ansible-vault password** to decrypt your SSH private key. This is the memorized password — no other credentials needed.

The installer runs these stages in order:

1. **SSH keys** — decrypts `.ssh/id_ed25519.vault` → `~/.ssh/id_ed25519`
2. **Shell** — installs zsh (Linux), oh-my-zsh, zsh-autosuggestions
3. **Symlinks** — all dotfiles, git configs, SSH config, tool configs
4. **VS Code** — settings + keybindings to platform-correct path
5. **Scripts** — copies `scripts/` → `~/scripts`
6. **Packages** — Brewfile (macOS) or Aptfile + Snapfile (Linux), Claude CLI, Rust

Each stage is idempotent — safe to re-run.

## Step 4: Configure Secrets

The installer creates `~/.secret_env_vars` with a template. Fill it in:

```bash
vim ~/.secret_env_vars
```

```bash
# Required for @dfinitiv npm packages
export GITHUB_TOKEN="ghp_your_github_token"

# Optional
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export API_KEY=""
```

This file is `chmod 600` and gitignored. It's sourced by `.zshrc` on every shell startup.

**Why GITHUB_TOKEN matters:** The `.npmrc` uses `${GITHUB_TOKEN}` to authenticate with GitHub Packages for `@dfinitiv`-scoped npm packages. Without it, `npm install` will fail on Dfinitiv projects.

## Step 5: Reload Shell

```bash
source ~/.zshrc
```

Or start a new terminal session.

## Step 6: Clone All Repos

Now that your SSH key is decrypted and in place:

```bash
./clone-repos.sh
```

This clones 100+ repos into organized directories:

```
~/Development/
  Dfinitiv/      # 40+ work repos
  Personal/      # 60+ personal projects
  Open-Source/    # Forks and references
  MCP-Servers/   # MCP server repos
```

## Step 7: AWS SSO

```bash
# Primary profile
aws sso login --profile dfinitiv-brian

# Verify
aws sts get-caller-identity --profile dfinitiv-brian
```

Available profiles (defined in `.aws/config`):
- `dfinitiv-brian` — main admin
- `dfinitiv-mojo-dev-power-user`
- `dfinitiv-mojo-test-power-user`
- `dfinitiv-mojo-prod-power-user`

Use the `sso` shell function to interactively switch profiles.

See [AWS.md](AWS.md) for details.

## Verification Checklist

Run through these to confirm everything's working:

```bash
# SSH key works
ssh -T git@github.com
# → "Hi BrianVia! You've successfully authenticated..."

# Shell is zsh with oh-my-zsh
echo $SHELL           # /bin/zsh
echo $ZSH_THEME       # robbyrussell

# Claude CLI installed
claude --version

# Aliases work
gs                    # git status
sendit                # add all, commit "full send", push

# Scripts accessible
which timer.sh        # ~/scripts/timer.sh
hoy                   # today's date + calendar

# Git identity
git config user.name  # "Brian Via"

# AWS (if configured)
aws sts get-caller-identity --profile dfinitiv-brian

# 1Password SSH agent (if 1Password installed)
ssh-add -l            # should list your key
```

## Troubleshooting

### "ansible-vault: command not found"

Install ansible before running the installer:
- macOS: `brew install ansible`
- Linux: `sudo apt install ansible`

### SSH key decrypt fails / wrong password

The vault password is the memorized one — no special characters, no newline. If you fat-finger it, just re-run `./install.sh` — it'll skip stages that already completed and re-prompt for the vault password.

To manually re-decrypt:
```bash
rm ~/.ssh/id_ed25519
cp ~/Development/Personal/dotfiles/.ssh/id_ed25519.vault ~/.ssh/id_ed25519
ansible-vault decrypt ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
```

### "Command not found" after install

Reload your shell:
```bash
source ~/.zshrc
# or
exec zsh
```

### Symlinks not created

Re-run the installer — it's idempotent:
```bash
~/Development/Personal/dotfiles/install.sh
```

### npm install fails on @dfinitiv packages

Set your GitHub token:
```bash
echo 'export GITHUB_TOKEN="ghp_your_token"' >> ~/.secret_env_vars
source ~/.zshrc
```

### brew command not found (macOS)

Homebrew needs to be in your PATH. The `.zprofile` handles this, but on first install before symlinks exist:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Scripts not in PATH

Verify `~/scripts` is in your PATH:
```bash
echo $PATH | tr ':' '\n' | grep scripts
```

If missing, re-run `source ~/.zshrc` — the PATH is set there.

### Git clone fails (permission denied)

Your SSH key isn't loaded. Check:
```bash
ssh-add -l                           # list loaded keys
ssh-add ~/.ssh/id_ed25519            # add if missing
ssh -T git@github.com               # test connection
```

### 1Password SSH agent not working

The `.ssh/config` uses `Match` blocks to auto-detect the platform-correct socket:
- macOS: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- Linux: `~/.1password/agent.sock`

Make sure 1Password is installed and SSH agent is enabled in 1Password settings.

## Platform Notes

### macOS
- Zsh is the default shell since Catalina
- Karabiner config is symlinked (keyboard remapping)
- Amazon Q integration is active
- Android SDK path: `~/Library/Android/sdk`

### Linux (Ubuntu/Debian)
- Zsh is installed and set as default shell by the installer
- Karabiner is skipped (macOS only)
- Amazon Q blocks are skipped
- Snap packages installed for GUI apps (VS Code, Slack, Discord, etc.)
- Android SDK path: `~/Android/Sdk`

### WSL2
- Works like Linux — use the Linux install path
- Some macOS-specific scripts (pbcopy, desktop notifications) won't work
- SSH keys and git work identically to native Linux

## Updating

After the initial setup, pull and re-run:

```bash
cd ~/Development/Personal/dotfiles
git pull
./install.sh
source ~/.zshrc
```

The installer is idempotent — existing symlinks, SSH keys, and oh-my-zsh are skipped. Only new/changed things are applied.
