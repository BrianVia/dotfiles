#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Dotfiles Installation${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Home directory: $HOME_DIR"
echo ""

# Function to create symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$src")

    if [ -L "$dest" ]; then
        # Already a symlink
        echo -e "${YELLOW}→${NC} Symlink exists: $name"
    elif [ -e "$dest" ]; then
        # File exists, back it up
        echo -e "${YELLOW}⚠ Backing up existing file:${NC} $name"
        mv "$dest" "${dest}.backup.$(date +%s)"
        ln -s "$src" "$dest"
        echo -e "${GREEN}✓${NC} Symlinked: $name"
    else
        # Create new symlink
        ln -s "$src" "$dest"
        echo -e "${GREEN}✓${NC} Symlinked: $name"
    fi
}

# Create .aws directory if it doesn't exist
echo -e "${BLUE}Setting up AWS configuration...${NC}"
mkdir -p "$HOME_DIR/.aws/cli"
create_symlink "$DOTFILES_DIR/.aws/config" "$HOME_DIR/.aws/config"
echo ""

# Symlink shell configuration files
echo -e "${BLUE}Setting up shell configuration...${NC}"
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME_DIR/.zshrc"
create_symlink "$DOTFILES_DIR/.zprofile" "$HOME_DIR/.zprofile"
create_symlink "$DOTFILES_DIR/.zshenv" "$HOME_DIR/.zshenv"
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME_DIR/.bashrc"
create_symlink "$DOTFILES_DIR/.profile" "$HOME_DIR/.profile"
create_symlink "$DOTFILES_DIR/.development_aliases" "$HOME_DIR/.development_aliases"
create_symlink "$DOTFILES_DIR/.personal_aliases" "$HOME_DIR/.personal_aliases"
echo ""

# Symlink git configuration
echo -e "${BLUE}Setting up git configuration...${NC}"
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME_DIR/.gitconfig"
create_symlink "$DOTFILES_DIR/.gitconfig-work" "$HOME_DIR/.gitconfig-work"
create_symlink "$DOTFILES_DIR/.gitconfig-personal" "$HOME_DIR/.gitconfig-personal"
echo ""

# Symlink package manager configs
echo -e "${BLUE}Setting up package manager configs...${NC}"
create_symlink "$DOTFILES_DIR/.npmrc" "$HOME_DIR/.npmrc"
create_symlink "$DOTFILES_DIR/.yarnrc" "$HOME_DIR/.yarnrc"
echo ""

# Symlink SSH config (not keys)
echo -e "${BLUE}Setting up SSH config...${NC}"
mkdir -p "$HOME_DIR/.ssh"
create_symlink "$DOTFILES_DIR/.ssh/config" "$HOME_DIR/.ssh/config"
echo ""

# Symlink tool configs
echo -e "${BLUE}Setting up tool configurations...${NC}"
mkdir -p "$HOME_DIR/.config/ghostty"
mkdir -p "$HOME_DIR/.config/karabiner"
create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME_DIR/.config/ghostty/config"
create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME_DIR/.config/starship.toml"
create_symlink "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$HOME_DIR/.config/karabiner/karabiner.json"
echo ""

# VS Code settings
echo -e "${BLUE}Setting up VS Code...${NC}"
VSCODE_DIR="$HOME_DIR/Library/Application Support/Code/User"
if [ -d "$VSCODE_DIR" ] || [ -d "/Applications/Visual Studio Code.app" ]; then
    mkdir -p "$VSCODE_DIR"
    create_symlink "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
    create_symlink "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"
else
    echo -e "${YELLOW}→${NC} VS Code not found, skipping"
fi
echo ""

# Make scripts directory in home if it doesn't exist
echo -e "${BLUE}Setting up scripts...${NC}"
mkdir -p "$HOME_DIR/scripts"
# Copy scripts instead of symlinking (so PATH can find them directly)
rsync -av --exclude='node_modules' --exclude='*.log' --exclude='bun.lock' "$DOTFILES_DIR/scripts/" "$HOME_DIR/scripts/" > /dev/null
chmod +x "$HOME_DIR/scripts"/*.sh "$HOME_DIR/scripts"/*.rb "$HOME_DIR/scripts"/*.py 2>/dev/null || true
echo -e "${GREEN}✓${NC} Scripts installed to ~/scripts"
echo ""

# Setup .secret_env_vars file (if needed)
if [ ! -f "$HOME_DIR/.secret_env_vars" ]; then
    echo -e "${YELLOW}⚠ Creating .secret_env_vars template...${NC}"
    cat > "$HOME_DIR/.secret_env_vars" << 'EOF'
# Secret environment variables (NEVER commit this file)
# Add your secrets here:

# AWS (if not using SSO)
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""

# GitHub token
# export GITHUB_TOKEN=""

# Other secrets
# export API_KEY=""
EOF
    chmod 600 "$HOME_DIR/.secret_env_vars"
    echo -e "${GREEN}✓${NC} Created .secret_env_vars (chmod 600)"
fi
echo ""

# Setup AWS credentials file if it doesn't exist
if [ ! -f "$HOME_DIR/.aws/credentials" ]; then
    echo -e "${YELLOW}⚠ AWS credentials file not found${NC}"
    echo -e "   You can:"
    echo -e "   1. Copy your credentials: ${BLUE}cp ~/.aws/credentials ~/Development/Personal/dotfiles/.aws/credentials.example${NC}"
    echo -e "   2. Use 1Password: ${BLUE}op signin${NC} and set AWS_ACCESS_KEY_ID via environment"
    echo -e "   3. Use AWS SSO: ${BLUE}aws sso login --profile <profile-name>${NC}"
fi
echo ""

# Install Homebrew packages
if command -v brew &> /dev/null; then
    echo -e "${BLUE}Installing Homebrew packages...${NC}"
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Homebrew packages installed"
    fi
else
    echo -e "${YELLOW}⚠ Homebrew not found. Install it first:${NC}"
    echo -e "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi
echo ""

# Install oh-my-zsh if not present
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    echo -e "${BLUE}Installing oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Install zsh-autosuggestions plugin
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} oh-my-zsh installed"
fi
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Review ~/.secret_env_vars and add your secrets"
echo "  2. Copy SSH keys from your old machine (or generate new ones)"
echo "  3. Authenticate AWS SSO: ${BLUE}aws sso login --profile dfinitiv-brian${NC}"
echo "  4. Clone repos: ${BLUE}$DOTFILES_DIR/clone-repos.sh${NC}"
echo "  5. Reload shell: ${BLUE}source ~/.zshrc${NC}"
echo ""
