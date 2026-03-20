# dotfiles

Personal dotfiles, scripts, and machine bootstrap tooling for **macOS and Linux**.

One repo to rule them all — clone over HTTPS on a blank machine, decrypt your SSH keys with a memorized password, and you're fully bootstrapped.

## Fresh Machine Install (from scratch)

You're sitting in front of a blank machine. No SSH key, no tools, nothing. Here's the play:

### 1. Install prerequisites

**macOS:**
```bash
# Xcode command line tools (gives you git)
xcode-select --install

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ansible (needed to decrypt SSH keys)
brew install ansible
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install -y git curl ansible
```

### 2. Clone this repo (HTTPS — no SSH key needed yet)

```bash
mkdir -p ~/Development/Personal
git clone https://github.com/BrianVia/dotfiles.git ~/Development/Personal/dotfiles
cd ~/Development/Personal/dotfiles
```

### 3. Run the installer

```bash
./install.sh
```

This runs through 6 stages in order:

| Stage | What happens |
|-------|-------------|
| **SSH keys** | Copies vault-encrypted private key to `~/.ssh/`, prompts for vault password, decrypts in place |
| **Shell** | Installs oh-my-zsh + zsh-autosuggestions (Linux: installs zsh, changes default shell) |
| **Symlinks** | Links all dotfiles to `~` — shell configs, git configs, SSH config, tool configs. macOS-only files (Karabiner) are guarded |
| **VS Code** | Symlinks settings + keybindings to platform-correct path |
| **Scripts** | Copies `scripts/` to `~/scripts` |
| **Packages** | Brewfile on macOS, Aptfile + Snapfile on Linux, Claude CLI + Rust on both |

### 4. Set up secrets

```bash
vim ~/.secret_env_vars
```

Add at minimum:
```bash
export GITHUB_TOKEN="ghp_your_token_here"  # needed for @dfinitiv npm packages
```

### 5. Reload shell

```bash
source ~/.zshrc
```

### 6. Clone all repos

```bash
./clone-repos.sh
```

This clones 100+ work and personal repos into `~/Development/` using your now-decrypted SSH key.

### 7. AWS SSO

```bash
aws sso login --profile dfinitiv-brian
```

See [docs/AWS.md](docs/AWS.md) for all profiles and troubleshooting.

## Verify everything works

```bash
# SSH
ssh -T git@github.com                        # "Hi BrianVia!"

# Shell
echo $SHELL                                   # /bin/zsh
which claude                                  # Claude CLI installed

# Aliases
gs                                            # git status
sendit                                        # add all, commit, push

# Scripts
timer 1m                                      # desktop notification timer
hoy                                           # today's date + calendar

# AWS
aws sts get-caller-identity --profile dfinitiv-brian

# Git
git config --global user.name                 # "Brian Via"
```

---

## SSH Keys (ansible-vault)

The private key at `.ssh/id_ed25519.vault` is encrypted with [ansible-vault](https://docs.ansible.com/ansible/latest/vault_guide/) (AES256). The public key `.ssh/id_ed25519.pub` is plaintext.

During install, you're prompted for the vault password. The encrypted file is copied to `~/.ssh/id_ed25519` and decrypted in place. If a key already exists at the destination, it's skipped entirely.

## Platform Support

| Feature | macOS | Linux |
|---------|-------|-------|
| SSH key decrypt | ✓ | ✓ |
| oh-my-zsh | ✓ | ✓ (installs zsh first) |
| Dotfile symlinks | ✓ | ✓ |
| Karabiner | ✓ | — |
| VS Code settings | ✓ | ✓ |
| Packages | Brewfile | Aptfile + Snapfile |
| Claude CLI | ✓ | ✓ |
| Amazon Q | ✓ | — |
| 1Password SSH agent | ✓ | ✓ (different socket path) |
| Android SDK | `~/Library/Android/sdk` | `~/Android/Sdk` |

## Directory Structure

```
.
├── setup/              # Modular setup scripts
│   ├── common.sh       # Shared utilities (colors, detect_os, create_symlink)
│   ├── ssh.sh          # SSH key deployment + vault decrypt
│   ├── shell.sh        # Zsh + oh-my-zsh
│   ├── symlinks.sh     # Dotfile symlinking
│   ├── vscode.sh       # VS Code settings
│   ├── scripts.sh      # ~/scripts deployment
│   └── packages.sh     # Platform-aware package install + Claude CLI
├── docker/             # Docker-based Linux testing
│   ├── Dockerfile
│   └── build.sh
├── scripts/            # Utility scripts (copied to ~/scripts)
├── vscode/             # VS Code settings + keybindings
├── .ssh/
│   ├── config          # SSH config (platform-aware 1Password agent)
│   ├── id_ed25519.vault # Encrypted private key (ansible-vault)
│   └── id_ed25519.pub  # Public key
├── Brewfile            # macOS Homebrew packages
├── Aptfile             # Linux apt packages
├── Snapfile            # Linux snap packages
├── install.sh          # Main orchestrator
├── clone-repos.sh      # Clone 100+ repos
└── README.md
```

## What's In Here

### Shell

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config — plugins, PATH, AWS SSO switcher, bun/Java/Android SDK setup |
| `.zprofile` | Zsh profile init (platform-guarded Homebrew + Amazon Q) |
| `.zshenv` | Zsh environment variables |
| `.bashrc` | Bash fallback |
| `.profile` | POSIX profile, sourced by `.zshrc` |

### Aliases

**`.development_aliases`** — daily driver shortcuts:

| Alias | What it does |
|-------|-------------|
| `gs` / `gp` / `gpu` | git status / push / pull |
| `ga` / `gc` / `gm` | git add -a / checkout / commit -am |
| `mm` / `bb` | merge master / back to previous branch |
| `sendit` | add all, commit "full send", push |
| `brs` / `brd` / `brt` | bun run start / dev / test |
| `dcu` / `dc` / `dcd` | docker-compose up / exec / down |
| `eda` / `epa` / `ez` | edit aliases / personal aliases / zshrc |

**`.personal_aliases`** — personal workflow (`src`, `ccy`, `coy`, `cdp`, `tf`)

### Git

| File | Purpose |
|------|---------|
| `.gitconfig` | Default user (personal), conditional includes for work/personal paths, `gh auth` credential helper |
| `.gitconfig-work` | Auto-applied in `~/Development/Dfinitiv/` |
| `.gitconfig-personal` | Auto-applied in `~/Development/Personal/` |

### Tool Configs

| File | Purpose |
|------|---------|
| `.config/starship.toml` | Starship prompt |
| `.config/ghostty/config` | Ghostty terminal settings |
| `.config/karabiner/karabiner.json` | Keyboard remapping (macOS only) |
| `.ssh/config` | SSH config with platform-aware 1Password agent |
| `.npmrc` | npm config — uses `${GITHUB_TOKEN}` env var for GitHub Packages auth |
| `.yarnrc` | Yarn config |

## Docker Testing (Linux)

Test the full Linux install path without a real machine:

```bash
cd docker
./build.sh
docker run -it dotfiles-test
```

Builds an Ubuntu container with ansible pre-installed, copies dotfiles in, runs `install.sh`. The vault decrypt step will prompt for the password interactively.

## Security

Gitignored — never committed:

- `.aws/credentials` and `.aws/sso/` — AWS keys and session tokens
- `.secret_env_vars` — environment secrets (including `GITHUB_TOKEN`)
- `.env` / `.env.*` — local environment files
- SSH private keys (only the vault-encrypted `.vault` file is committed)

The `.npmrc` uses `${GITHUB_TOKEN}` as an env var reference — the actual token lives in `~/.secret_env_vars`, not in this repo.

## Updating

After pulling new changes:

```bash
cd ~/Development/Personal/dotfiles
git pull
./install.sh     # re-runs symlinks, skips existing SSH keys/oh-my-zsh
source ~/.zshrc
```

The installer is idempotent — it skips anything already in place and backs up conflicting files.

## Docs

- [docs/SETUP.md](docs/SETUP.md) — detailed step-by-step setup guide with troubleshooting
- [docs/AWS.md](docs/AWS.md) — AWS SSO config, profile switching, troubleshooting
