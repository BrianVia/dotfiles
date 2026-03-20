#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$DOTFILES_DIR/setup"

# Source common utilities (colors, detect_os, create_symlink)
source "$SETUP_DIR/common.sh"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Dotfiles Installation ($OS)${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Home directory: $HOME_DIR"
echo "Platform: $OS"
echo ""

# 1. SSH keys — first, since repo cloning needs SSH
source "$SETUP_DIR/ssh.sh"

# 2. Zsh + oh-my-zsh — before symlinking .zshrc
source "$SETUP_DIR/shell.sh"

# 3. Symlink all config files
source "$SETUP_DIR/symlinks.sh"

# 4. VS Code settings (platform-aware)
source "$SETUP_DIR/vscode.sh"

# 5. Deploy ~/scripts
source "$SETUP_DIR/scripts.sh"

# 6. Packages (brew on macOS, apt/snap on Linux, Claude CLI on both)
source "$SETUP_DIR/packages.sh"

# Create .secret_env_vars template
if [ ! -f "$HOME_DIR/.secret_env_vars" ]; then
    section "Creating .secret_env_vars template..."
    cat > "$HOME_DIR/.secret_env_vars" << 'EOF'
# Secret environment variables (NEVER commit this file)
# Add your secrets here:

# AWS (if not using SSO)
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""

# GitHub token (used by .npmrc for GitHub Packages)
# export GITHUB_TOKEN=""

# Other secrets
# export API_KEY=""
EOF
    chmod 600 "$HOME_DIR/.secret_env_vars"
    echo -e "${GREEN}✓${NC} Created .secret_env_vars (chmod 600)"
fi

# Setup AWS credentials file guidance
if [ ! -f "$HOME_DIR/.aws/credentials" ]; then
    echo ""
    echo -e "${YELLOW}⚠ AWS credentials file not found${NC}"
    echo "  Use AWS SSO: aws sso login --profile dfinitiv-brian"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Review ~/.secret_env_vars and add your secrets (GITHUB_TOKEN for npm)"
echo "  2. Authenticate AWS SSO: aws sso login --profile dfinitiv-brian"
echo "  3. Clone repos: $DOTFILES_DIR/clone-repos.sh"
echo "  4. Reload shell: source ~/.zshrc"
echo ""
