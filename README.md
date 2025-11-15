# Dotfiles Repository

Personal dotfiles and scripts for a fully portable development environment. This repository contains all shell configuration, aliases, scripts, and AWS setup needed to quickly bootstrap a new macOS or Linux system.

## What's Included

### 📁 Directory Structure

```
dotfiles/
├── .zshrc                    # Zsh shell configuration
├── .bashrc                   # Bash shell configuration
├── .profile                  # Shell profile (sourced by .zshrc)
├── .development_aliases      # Development-related aliases (git, docker, etc.)
├── .personal_aliases         # Personal quick aliases
├── .npmrc                    # NPM configuration
├── .yarnrc                   # Yarn configuration
├── .gitignore                # Files to never commit (secrets, credentials)
├── scripts/                  # Utility scripts (21 scripts included)
│   ├── copy_clipboard.sh     # Copy to clipboard
│   ├── paste_clipboard.sh    # Paste from clipboard
│   ├── timer.sh              # Simple timer utility
│   ├── hoy.sh                # Today's date utility
│   ├── serveit.sh            # Quick dev server
│   ├── notify.rb             # Desktop notifications
│   ├── running.sh            # Show running processes
│   ├── rn.sh                 # Random name generator
│   ├── linear-daily-summary.sh    # Linear.app integration
│   ├── get-yesterdays-work.sh     # Work tracking
│   ├── fetch-readme.ts       # GitHub README fetcher
│   └── ...and more
├── .aws/                     # AWS configuration (version controlled)
│   └── config                # AWS profiles and SSO settings
├── docs/                     # Documentation
│   ├── AWS.md                # AWS configuration guide
│   └── SETUP.md              # Setup instructions
└── install.sh                # Installation script (symlinks everything)
```

### 📝 What's NOT Included (For Security)

These files are in `.gitignore` and never committed:
- `.aws/credentials` - AWS API keys
- `.aws/sso/` - SSO session tokens
- `.secret_env_vars` - Environment variables with secrets
- `.env` files - Local environment configuration

## Quick Start

### First Time Setup

```bash
# Clone the dotfiles repo
git clone git@github.com:BrianVia/dotfiles.git ~/Development/Personal/dotfiles

# Run the installation script
cd ~/Development/Personal/dotfiles
./install.sh

# Reload your shell
source ~/.zshrc
```

The `install.sh` script will:
- ✅ Create symlinks for all dotfiles in your home directory
- ✅ Back up any existing files (with timestamp)
- ✅ Copy scripts to `~/scripts`
- ✅ Create `~/.secret_env_vars` template
- ✅ Set up `.aws` directories

### After Installation

1. **Set up AWS SSO:**
   ```bash
   aws sso login --profile dfinitiv-brian
   aws sso login --profile dfinitiv-mojo-dev-power-user
   ```

2. **Add your secrets to `~/.secret_env_vars`:**
   ```bash
   vim ~/.secret_env_vars
   ```

3. **Test your setup:**
   ```bash
   echo $DEV_USER_ID          # Should print: ef4a1216-72d4-4456-9c12-0c801a6a78bf
   which timer                # Should be: /Users/via/scripts/timer.sh
   gs                         # Should run: git status
   ```

## Key Features

### 🚀 Development Aliases

Quick git commands:
```bash
gs                 # git status
gp                 # git push
gpu                # git pull
ga                 # git add -a
mm                 # merge master into current branch
bb                 # go back to previous branch
```

### 🔧 Utility Scripts

- **Clipboard**: `copy` / `pasta` - Copy/paste from terminal
- **Dev Server**: `serveit` - Quick HTTP server
- **Timers**: `timer 5m` - Set a timer
- **Utilities**: `hoy`, `running`, `rn`, `notify`

### 🌐 AWS Configuration

Pre-configured SSO profiles for multiple AWS accounts:
- `dfinitiv-brian`
- `dfinitiv-mojo-dev-power-user`
- `dfinitiv-mojo-test-power-user`
- `dfinitiv-mojo-prod-power-user`

See [AWS.md](docs/AWS.md) for detailed setup.

### 🛠️ Package Manager Configs

- NPM configuration in `.npmrc`
- Yarn configuration in `.yarnrc`

## Customization

### Adding New Aliases

Edit the alias files directly:
```bash
eda                # Edit development aliases
epa                # Edit personal aliases
ez                 # Edit .zshrc
```

Changes take effect immediately or after `source ~/.zshrc`.

### Adding New Scripts

1. Add script to `scripts/` directory
2. Make it executable: `chmod +x scripts/my-script.sh`
3. Run `./install.sh` or manually copy to `~/scripts`

### Machine-Specific Configuration

For machine-specific settings, create a `.zshrc.local` file:

```bash
# ~/.zshrc.local (not committed)
# Add machine-specific aliases, functions, or env vars here
```

This is sourced at the end of `.zshrc` if it exists.

## Integration with Ansible

This dotfiles repo is installed via Ansible during system setup:

```bash
# In your ansible/tasks/dotfiles.yml
- name: Clone dotfiles repository
  ansible.builtin.git:
    repo: "git@github.com:BrianVia/dotfiles.git"
    dest: "{{ lookup('env', 'HOME') }}/Development/Personal/dotfiles"
  tags:
    - dotfiles

- name: Run dotfiles installation
  shell: "{{ lookup('env', 'HOME') }}/Development/Personal/dotfiles/install.sh"
  tags:
    - dotfiles
```

## Platform Support

### macOS ✅
Fully tested and maintained.

### Linux (Ubuntu/Debian) ✅
Most scripts work on Linux. Some aliases may need adjustment for different shell defaults.

### WSL2 (Windows Subsystem for Linux) ✅
Your `.zshrc` includes WSL2 detection. Set `IS_WSL2=true` if running in WSL.

## Troubleshooting

### Symlinks Not Working

If symlinks aren't created correctly:
```bash
./install.sh  # Re-run the installation script
```

### Shell Not Loading Aliases

Reload your shell:
```bash
source ~/.zshrc
```

Or open a new terminal window.

### Scripts Not Found

Make sure `~/scripts` is in your PATH:
```bash
echo $PATH | grep scripts
```

Should show: `/Users/via/scripts`

### AWS SSO Issues

See [AWS.md](docs/AWS.md#troubleshooting) for AWS-specific troubleshooting.

## Files to Keep Secret

These files are critical for security - **NEVER** commit them:

- `~/.aws/credentials` - AWS API keys
- `~/.secret_env_vars` - Environment secrets
- `~/.ssh/id_ed25519` - SSH private key
- Any `.env` or `.env.local` files

If you accidentally commit secrets:
```bash
git rm --cached .secret_env_vars  # Remove from tracking
git commit -m "Remove secrets"
# Consider rotating your credentials!
```

## Updating Dotfiles

When you update this repo on another machine:

```bash
cd ~/Development/Personal/dotfiles
git pull origin main
./install.sh  # Re-create symlinks if needed
source ~/.zshrc
```

## Version Control

- Always use `.gitignore` - secrets are protected ✅
- Aliases and scripts are safe to share ✅
- AWS profiles are safe to share ✅
- Credentials and tokens are never committed ✅

## Contributing

To add new features to dotfiles:

1. Test locally
2. Commit to git
3. Push to repository
4. Run `./install.sh` on other machines

## References

- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [AWS SSO](https://docs.aws.amazon.com/singlesignon/)
- [GitHub Secrets Protection](https://docs.github.com/en/code-security/secret-scanning)

## License

Personal dotfiles - use as reference for your own setup.

## Contact

- GitHub: [@BrianVia](https://github.com/BrianVia)
- Email: brian.via.dev@gmail.com

---

**Last Updated**: 2025-11-15
**Total Scripts**: 21
**Total Aliases**: 60+
**Supported Shells**: Zsh (primary), Bash
