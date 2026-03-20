#!/bin/bash
# Platform-aware package installation
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

section "Installing packages..."

if is_macos; then
    if command -v brew &>/dev/null; then
        if [ -f "$DOTFILES_DIR/Brewfile" ]; then
            echo -e "${BLUE}Installing Homebrew packages...${NC}"
            brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Homebrew packages installed"
        fi
    else
        echo -e "${YELLOW}⚠ Homebrew not found. Install it first:${NC}"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi
fi

if is_linux; then
    # Apt packages
    if [ -f "$DOTFILES_DIR/Aptfile" ]; then
        echo -e "${BLUE}Installing apt packages...${NC}"
        # Filter comments and blank lines
        PACKAGES=$(grep -v '^#' "$DOTFILES_DIR/Aptfile" | grep -v '^$' | tr '\n' ' ')
        sudo apt-get update -qq
        sudo apt-get install -y $PACKAGES
        echo -e "${GREEN}✓${NC} Apt packages installed"
    fi

    # Snap packages
    if [ -f "$DOTFILES_DIR/Snapfile" ] && command -v snap &>/dev/null; then
        echo -e "${BLUE}Installing snap packages...${NC}"
        while IFS= read -r line; do
            # Skip comments and blank lines
            [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
            echo -e "  Installing: $line"
            sudo snap install $line 2>/dev/null || echo -e "  ${YELLOW}⚠${NC} Failed: $line"
        done < "$DOTFILES_DIR/Snapfile"
        echo -e "${GREEN}✓${NC} Snap packages installed"
    fi

    # Rust via rustup
    if ! command -v rustc &>/dev/null; then
        echo -e "${BLUE}Installing Rust via rustup...${NC}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        echo -e "${GREEN}✓${NC} Rust installed"
    else
        echo -e "${YELLOW}→${NC} Rust already installed"
    fi
fi

# Claude CLI (both platforms)
if ! command -v claude &>/dev/null; then
    echo -e "${BLUE}Installing Claude CLI...${NC}"
    curl -fsSL https://claude.ai/install.sh | bash
    echo -e "${GREEN}✓${NC} Claude CLI installed"
else
    echo -e "${YELLOW}→${NC} Claude CLI already installed"
fi
