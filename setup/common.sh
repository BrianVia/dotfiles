#!/bin/bash
# Shared utilities for dotfiles setup

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="$HOME"

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

OS="$(detect_os)"

is_macos() { [[ "$OS" == "macos" ]]; }
is_linux() { [[ "$OS" == "linux" ]]; }

create_symlink() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$src")

    if [ -L "$dest" ]; then
        echo -e "${YELLOW}→${NC} Symlink exists: $name"
    elif [ -e "$dest" ]; then
        echo -e "${YELLOW}⚠ Backing up existing file:${NC} $name"
        mv "$dest" "${dest}.backup.$(date +%s)"
        ln -s "$src" "$dest"
        echo -e "${GREEN}✓${NC} Symlinked: $name"
    else
        ln -s "$src" "$dest"
        echo -e "${GREEN}✓${NC} Symlinked: $name"
    fi
}

section() {
    echo ""
    echo -e "${BLUE}$1${NC}"
}
