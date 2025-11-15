# Setup Instructions for New Machine

Complete guide to set up a new macOS or Linux machine with this dotfiles repository.

## Prerequisites

- Git installed
- SSH key set up (or use HTTPS clone)
- Zsh or Bash shell available
- macOS 10.13+ or Ubuntu/Debian

## Step 1: Initial System Setup (If Using Ansible)

If using Ansible to automate setup:

```bash
# On a new Ubuntu/Linux machine
./install  # Run the Ansible installer

# Or manually
ansible-playbook ~/Development/Personal/ansible/local.yml
```

This will install:
- SSH configuration
- Zsh with Oh-My-Zsh
- Development tools
- All your projects

## Step 2: Clone Dotfiles Repository

After Ansible setup (or manually):

```bash
# Clone the dotfiles repo
git clone git@github.com:BrianVia/dotfiles.git ~/Development/Personal/dotfiles

# Navigate to the directory
cd ~/Development/Personal/dotfiles
```

If you don't have SSH set up yet, use HTTPS:
```bash
git clone https://github.com/BrianVia/dotfiles.git ~/Development/Personal/dotfiles
```

## Step 3: Run Installation Script

```bash
# Make sure it's executable
chmod +x ~/Development/Personal/dotfiles/install.sh

# Run the installation
~/Development/Personal/dotfiles/install.sh
```

The script will:
- Create symlinks for all dotfiles
- Back up any existing files
- Copy scripts to `~/scripts`
- Create `.secret_env_vars` template
- Set up `.aws` directories

## Step 4: Reload Shell

```bash
# Reload zsh
exec zsh

# Or source manually
source ~/.zshrc
```

## Step 5: Set Up AWS (SSO)

### If using AWS SSO (Recommended):

```bash
# Login to your AWS SSO profiles
aws sso login --profile dfinitiv-brian
aws sso login --profile dfinitiv-mojo-dev-power-user
aws sso login --profile dfinitiv-mojo-test-power-user
aws sso login --profile dfinitiv-mojo-prod-power-user

# Verify it works
aws sts get-caller-identity --profile dfinitiv-brian
```

### If using API keys:

1. **Add credentials to 1Password** (recommended):
   ```bash
   op signin  # Authenticate
   ```

2. **Or create `~/.aws/credentials`** (less secure):
   ```bash
   # Edit: nano ~/.aws/credentials
   [dfinitiv-brian]
   aws_access_key_id = YOUR_KEY
   aws_secret_access_key = YOUR_SECRET
   ```
   **⚠️ Never commit this file!**

See [AWS.md](AWS.md) for more details.

## Step 6: Add Secret Environment Variables

1. **Edit the secrets file:**
   ```bash
   vim ~/.secret_env_vars
   ```

2. **Add your secrets:**
   ```bash
   # GitHub token
   export GITHUB_TOKEN="ghp_xxx..."

   # Other API keys
   export API_KEY="xxx..."
   ```

3. **Set proper permissions:**
   ```bash
   chmod 600 ~/.secret_env_vars
   ```

## Step 7: Verify Installation

Test that everything is set up correctly:

```bash
# Test aliases
gs                          # Should run: git status
eda                         # Should open .development_aliases in code

# Test scripts
timer 1m                    # Should start a 1-minute timer
which copy                  # Should show: /Users/via/scripts/copy_clipboard.sh

# Test environment variables
echo $DEV_USER_ID           # Should show: ef4a1216-72d4-4456-9c12-0c801a6a78bf
echo $PATH | grep scripts   # Should show scripts directory

# Test AWS
aws sts get-caller-identity --profile dfinitiv-brian

# Test git config
git config --global user.name
git config --global user.email
```

## Step 8: Optional - Set Up SSH Git

If not already configured:

```bash
# Copy your SSH key (from another machine or create new)
# Then configure git
gcud   # Sets git config for dfinitiv email
# or
gcup   # Sets git config for personal email
```

## Step 9: Clone Your Projects

The Ansible playbook should have already done this, but if not:

```bash
# Personal projects
ansible-playbook ~/Development/Personal/ansible/local.yml --tags "personal-projects"

# Dfinitiv projects
ansible-playbook ~/Development/Personal/ansible/local.yml --tags "dfinitiv-projects"
```

## Step 10: Machine-Specific Configuration (Optional)

Create a local override file for machine-specific settings:

```bash
# Create local zsh config (not tracked)
cat > ~/.zshrc.local << 'EOF'
# Machine-specific aliases and functions
alias work-vm="ssh user@work-vm"
export WORK_MACHINE=true
EOF

chmod 600 ~/.zshrc.local
```

This file is loaded automatically and not committed to git.

## Troubleshooting

### "Command not found" errors

**Solution**: Reload your shell
```bash
exec zsh
# or
source ~/.zshrc
```

### Symlinks not created

**Solution**: Re-run install script
```bash
~/Development/Personal/dotfiles/install.sh
```

### AWS SSO not working

**Solution**: Re-authenticate
```bash
aws sso login --profile dfinitiv-brian
aws sts get-caller-identity --profile dfinitiv-brian
```

### Scripts not found in PATH

**Solution**: Verify PATH includes scripts directory
```bash
echo $PATH | grep scripts
# If not, add this to .zshrc:
# export PATH="$HOME/scripts:$PATH"
```

### Git not finding SSH key

**Solution**: Add SSH key to ssh-agent
```bash
ssh-add ~/.ssh/id_ed25519
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```

### Permission denied on scripts

**Solution**: Make scripts executable
```bash
chmod +x ~/scripts/*.sh
chmod +x ~/scripts/*.rb
chmod +x ~/scripts/*.py
```

## Platform-Specific Notes

### macOS

- Uses zsh by default (since Catalina)
- Homebrew is recommended for package management
- Some scripts use macOS-specific commands (pbcopy, pbpaste)
- SSH keys should be in ~/.ssh/

### Linux (Ubuntu/Debian)

- Use `sudo apt update && sudo apt install` for packages
- Some aliases may need adjustment:
  ```bash
  # In .development_aliases, clipboard commands differ:
  # alias copy='xclip -selection clipboard'
  # alias pasta='xclip -selection clipboard -o'
  ```
- Zsh isn't default; install with: `sudo apt install zsh`

### WSL2 (Windows Subsystem for Linux)

- Runs Linux inside Windows
- SSH keys should work the same as Linux
- Some paths may differ (Windows drives mounted as /mnt/c/, etc.)
- Use WSL-specific package management (apt)

## Next Steps

1. ✅ Verify everything is working
2. 📝 Customize aliases and scripts as needed
3. 🔄 Test on another machine
4. 📚 Review documentation for advanced features

## Common Tasks

### Add a new alias

```bash
# Edit development aliases
eda

# Add your alias:
alias myalias='command here'

# Reload
source ~/.zshrc
```

### Add a new script

```bash
# Create script in ~/scripts
vim ~/scripts/myscript.sh

# Make it executable
chmod +x ~/scripts/myscript.sh

# Use immediately
myscript.sh
```

### Update dotfiles from repo

```bash
cd ~/Development/Personal/dotfiles
git pull origin main
./install.sh  # Re-create symlinks if needed
source ~/.zshrc
```

### Remove or modify symlink

```bash
# See what's symlinked
ls -la ~/ | grep "dotfiles"

# Remove symlink
rm ~/.zshrc

# Create new one manually
ln -s ~/Development/Personal/dotfiles/.zshrc ~/.zshrc
```

## Getting Help

- Check [AWS.md](AWS.md) for AWS-specific issues
- Review the main [README.md](../README.md)
- Check your script's help output: `script.sh --help`

## Support

- GitHub Issues: [BrianVia/dotfiles](https://github.com/BrianVia/dotfiles/issues)
- Email: brian.via.dev@gmail.com
