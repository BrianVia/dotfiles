# dotfiles

Personal dotfiles, scripts, and machine bootstrap tooling for macOS.

## Quick Start

```bash
git clone git@github.com:BrianVia/dotfiles.git ~/Development/Personal/dotfiles
cd ~/Development/Personal/dotfiles
./install.sh
source ~/.zshrc
```

`install.sh` will:
- Symlink all dotfiles to `~`
- Copy scripts to `~/scripts`
- Install Homebrew packages from `Brewfile`
- Install oh-my-zsh + zsh-autosuggestions
- Set up VS Code settings (if installed)
- Create a `~/.secret_env_vars` template (chmod 600)

After install, run `./clone-repos.sh` to clone 100+ work and personal repos into `~/Development/`.

## What's In Here

### Shell

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config — plugins, PATH, AWS SSO switcher, starship prompt, bun/Java/Android SDK setup |
| `.zprofile` | Zsh profile init |
| `.zshenv` | Zsh environment variables |
| `.bashrc` | Bash fallback |
| `.profile` | POSIX profile, sourced by `.zshrc` |
| `.zshrc.local.example` | Template for machine-specific overrides (not committed) |

### Aliases

**`.development_aliases`** — daily driver shortcuts:

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `gp` / `gpu` | `git push` / `git pull` |
| `ga` | `git add -a` |
| `gc` | `git checkout` |
| `gm` | `git commit -am` |
| `mm` | merge master into current branch |
| `bb` | `git checkout -` (back to previous branch) |
| `sendit` | add all, commit "full send", push |
| `copy` / `pasta` | clipboard utilities |
| `serveit` | quick dev server (PHP/Python/Ruby) |
| `timer` | desktop notification timer |
| `hoy` | today's date + calendar |
| `brs` / `brd` / `brt` | `bun run start/dev/test` |
| `dcu` / `dc` / `dcd` | docker-compose up/exec/down |
| `eda` / `epa` / `ez` | edit aliases / personal aliases / zshrc in VS Code |
| `ll` / `lr` | detailed listing / recent files |

**`.personal_aliases`** — personal workflow:

| Alias | Command |
|-------|---------|
| `src` | reload oh-my-zsh |
| `ccy` / `coy` | claude / codex yolo mode |
| `cdp` | `cd ~/Development/Personal/` |
| `tf` | `tail -f` with configurable line count |

### Git

| File | Purpose |
|------|---------|
| `.gitconfig` | Default user (personal), conditional includes for work/personal paths, `gh auth` credential helper |
| `.gitconfig-work` | Auto-applied in `~/Development/Dfinitiv/` |
| `.gitconfig-personal` | Auto-applied in `~/Development/Personal/` |

### AWS

| File | Purpose |
|------|---------|
| `.aws/config` | 4 SSO profiles: `dfinitiv-brian`, `dfinitiv-mojo-{dev,test,prod}-power-user` |
| `.aws/credentials.example` | Template (actual credentials are gitignored) |

See [docs/AWS.md](docs/AWS.md) for SSO setup and profile switching.

### Tool Configs

| File | Purpose |
|------|---------|
| `.config/starship.toml` | Starship prompt (minimal green `$`) |
| `.config/ghostty/config` | Ghostty terminal settings |
| `.config/karabiner/karabiner.json` | Keyboard remapping |
| `.ssh/config` | SSH config (keys are gitignored) |
| `.npmrc` | npm global prefix, GitHub Packages for `@dfinitiv` scope |
| `.yarnrc` | Yarn config |

### VS Code

| File | Purpose |
|------|---------|
| `vscode/settings.json` | Prettier as default formatter, no minimap, zoom level 2, material icons, git auto-fetch, Copilot |
| `vscode/keybindings.json` | Custom keyboard shortcuts |

Symlinked to `~/Library/Application Support/Code/User/` on install.

### Brewfile

40+ packages including: `ansible`, `awscli`, `ffmpeg`, `gh`, `htop`, `imagemagick`, `jq`, `starship`, `tmux`, `yt-dlp`, `stripe`, `graphite`

Casks: `1password-cli`, `blackhole-2ch`, `fig`, `macfuse`

VS Code extensions: `claude-code`, `copilot-chat`, `prettier`, `eslint`, `astro`, `svelte`

## Scripts

All scripts live in `scripts/` and get copied to `~/scripts` during install. Most are aliased in `.development_aliases`.

### Everyday Utilities

| Script | What it does |
|--------|-------------|
| `copy_clipboard.sh` / `paste_clipboard.sh` | Cross-platform clipboard (pbcopy/xclip/putclip) |
| `timer.sh` | Sleep timer with desktop notification via `notify.rb` |
| `hoy.sh` | Print today's date with calendar highlight |
| `serveit.sh` | Quick HTTP server (tries PHP, Python, Ruby) |
| `rn.sh` | Random name generator |
| `running.sh` | Show running processes |
| `notify.rb` | macOS desktop notifications |

### Git & Work Tracking

| Script | What it does |
|--------|-------------|
| `get-yesterdays-work.sh` | Scan `~/Development/Dfinitiv` for your commits in the last 24h |
| `get-yesterdays-work.py` | Python version of the above |
| `git_log_projects.sh` | Git log across multiple projects |
| `copy_changed_files.sh` | Copy changed files from git |
| `copy_directory_files.sh` | Copy all files from a directory |
| `linear-daily-summary.sh` | AI-powered daily work summary via Claude CLI + Linear MCP |

### AWS & Infrastructure

| Script | What it does |
|--------|-------------|
| `add-secret.ts` | Interactive CLI for AWS Secrets Manager (Bun + chalk) |
| `set-default-github-actions-secrets.sh` | Bulk-set GitHub Actions secrets |
| `find-all-lambdas-not-used.sh` | Find unused Lambda functions |
| `fetch-readme.ts` | Fetch READMEs from Dfinitiv npm packages, distribute to project docs |
| `migrate-marketing-assets.ts` | Internal Dfinitiv asset migration |

### Ralph Loop Agent

`scripts/ralph/` is an autonomous AI development loop (inspired by Geoffrey Huntley's technique). It uses the Anthropic SDK to iteratively work on tasks with configurable stop conditions.

| File | Purpose |
|------|---------|
| `agent.ts` | Core `RalphLoopAgent` class — loop state, tool use, cost tracking |
| `tools.ts` | Sandboxed tools: `readFile`, `writeFile`, `execute`, `glob`, `fileExists` |
| `conditions.ts` | Stop conditions: iteration count, token budget, cost ceiling, duration |
| `tracker.ts` | Token/cost tracking per API call |
| `example.ts` | Example: automated Jest-to-Vitest migration |

## Repo Cloning

`clone-repos.sh` clones 100+ repositories into organized directories:

```
~/Development/
  Dfinitiv/      # 35+ work repos (savvy-*, mojo-*, constructs, etc.)
  MCP-Servers/   # MCP server repos
  Open-Source/    # Forks and references
  Personal/      # 50+ personal projects
```

`repos.md` has the full manifest.

## Security

These are gitignored and never committed:

- `.aws/credentials` and `.aws/sso/` — AWS keys and session tokens
- `.secret_env_vars` — environment secrets
- `.env` / `.env.*` — local environment files
- SSH private keys

## Docs

- [docs/SETUP.md](docs/SETUP.md) — step-by-step setup guide
- [docs/AWS.md](docs/AWS.md) — AWS SSO config, profile switching, troubleshooting
- [scripts/README.md](scripts/README.md) — fetch-readme.ts cron setup
