#!/bin/bash
# Dotfile symlinking
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# AWS
section "Setting up AWS configuration..."
mkdir -p "$HOME_DIR/.aws/cli"
create_symlink "$DOTFILES_DIR/.aws/config" "$HOME_DIR/.aws/config"

# Shell configs
section "Setting up shell configuration..."
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME_DIR/.zshrc"
create_symlink "$DOTFILES_DIR/.zprofile" "$HOME_DIR/.zprofile"
create_symlink "$DOTFILES_DIR/.zshenv" "$HOME_DIR/.zshenv"
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME_DIR/.bashrc"
create_symlink "$DOTFILES_DIR/.profile" "$HOME_DIR/.profile"
create_symlink "$DOTFILES_DIR/.development_aliases" "$HOME_DIR/.development_aliases"
create_symlink "$DOTFILES_DIR/.personal_aliases" "$HOME_DIR/.personal_aliases"

# Git configs
section "Setting up git configuration..."
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME_DIR/.gitconfig"
create_symlink "$DOTFILES_DIR/.gitconfig-work" "$HOME_DIR/.gitconfig-work"
create_symlink "$DOTFILES_DIR/.gitconfig-personal" "$HOME_DIR/.gitconfig-personal"

# Package manager configs
section "Setting up package manager configs..."
# .npmrc needs token substitution — write a processed copy instead of symlinking
if [ -n "$GITHUB_TOKEN" ]; then
    envsubst < "$DOTFILES_DIR/.npmrc" > "$HOME_DIR/.npmrc"
    echo -e "${GREEN}✓${NC} .npmrc installed with GITHUB_TOKEN"
else
    create_symlink "$DOTFILES_DIR/.npmrc" "$HOME_DIR/.npmrc"
    echo -e "${YELLOW}⚠${NC} GITHUB_TOKEN not set — .npmrc symlinked as-is"
    echo "  Set GITHUB_TOKEN in ~/.secret_env_vars for GitHub Packages auth"
fi
create_symlink "$DOTFILES_DIR/.yarnrc" "$HOME_DIR/.yarnrc"

# SSH config
section "Setting up SSH config..."
mkdir -p "$HOME_DIR/.ssh"
create_symlink "$DOTFILES_DIR/.ssh/config" "$HOME_DIR/.ssh/config"

# Tool configs
section "Setting up tool configurations..."
mkdir -p "$HOME_DIR/.config/ghostty"
create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME_DIR/.config/ghostty/config"
create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME_DIR/.config/starship.toml"

# Karabiner is macOS-only
if is_macos; then
    mkdir -p "$HOME_DIR/.config/karabiner"
    create_symlink "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$HOME_DIR/.config/karabiner/karabiner.json"
fi

# Claude Code config
section "Setting up Claude Code configuration..."
mkdir -p "$HOME_DIR/.claude/commands" "$HOME_DIR/.claude/hooks"
create_symlink "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME_DIR/.claude/CLAUDE.md"
create_symlink "$DOTFILES_DIR/.claude/settings.json" "$HOME_DIR/.claude/settings.json"
for cmd in "$DOTFILES_DIR/.claude/commands"/*.md; do
    [ -f "$cmd" ] && create_symlink "$cmd" "$HOME_DIR/.claude/commands/$(basename "$cmd")"
done
for hook in "$DOTFILES_DIR/.claude/hooks"/*.sh; do
    [ -f "$hook" ] && create_symlink "$hook" "$HOME_DIR/.claude/hooks/$(basename "$hook")"
done

# Dfinitiv CLAUDE.md
section "Setting up Dfinitiv CLAUDE.md..."
mkdir -p "$HOME_DIR/Development/Dfinitiv"
create_symlink "$DOTFILES_DIR/dfinitiv-CLAUDE.md" "$HOME_DIR/Development/Dfinitiv/CLAUDE.md"
