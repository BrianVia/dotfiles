#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "Building dotfiles Docker image..."
docker build -f "$SCRIPT_DIR/Dockerfile" -t dotfiles-test "$DOTFILES_DIR"

echo ""
echo "Run with:  docker run -it dotfiles-test"
echo "Or interactive:  docker run -it dotfiles-test bash"
