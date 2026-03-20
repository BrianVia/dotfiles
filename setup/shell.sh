#!/bin/bash
# Zsh + oh-my-zsh setup
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

section "Setting up shell..."

# Install zsh on Linux if needed
if is_linux; then
    if ! command -v zsh &>/dev/null; then
        echo -e "${BLUE}Installing zsh...${NC}"
        sudo apt-get install -y zsh
    fi
    # Change default shell to zsh
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        echo -e "${BLUE}Changing default shell to zsh...${NC}"
        chsh -s "$(which zsh)"
        echo -e "${GREEN}✓${NC} Default shell changed to zsh (takes effect on next login)"
    fi
fi

# Install oh-my-zsh if not present
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    echo -e "${BLUE}Installing oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}✓${NC} oh-my-zsh installed"
else
    echo -e "${YELLOW}→${NC} oh-my-zsh already installed"
fi

# Install zsh-autosuggestions plugin
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "${BLUE}Installing zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} zsh-autosuggestions installed"
else
    echo -e "${YELLOW}→${NC} zsh-autosuggestions already installed"
fi
