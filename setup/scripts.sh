#!/bin/bash
# Deploy ~/scripts
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

section "Setting up scripts..."

mkdir -p "$HOME_DIR/scripts"
rsync -av --exclude='node_modules' --exclude='*.log' --exclude='bun.lock' "$DOTFILES_DIR/scripts/" "$HOME_DIR/scripts/" > /dev/null
chmod +x "$HOME_DIR/scripts"/*.sh "$HOME_DIR/scripts"/*.rb "$HOME_DIR/scripts"/*.py 2>/dev/null || true
echo -e "${GREEN}✓${NC} Scripts installed to ~/scripts"
