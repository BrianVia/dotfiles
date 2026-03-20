#!/bin/bash
# VS Code settings — platform-aware paths
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

section "Setting up VS Code..."

if is_macos; then
    VSCODE_DIR="$HOME_DIR/Library/Application Support/Code/User"
else
    VSCODE_DIR="$HOME_DIR/.config/Code/User"
fi

if [ -d "$VSCODE_DIR" ] || command -v code &>/dev/null; then
    mkdir -p "$VSCODE_DIR"
    create_symlink "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
    create_symlink "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"
else
    echo -e "${YELLOW}→${NC} VS Code not found, skipping"
fi
