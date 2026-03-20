#!/bin/bash
# SSH key deployment — decrypt ansible-vault encrypted keys
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

section "Setting up SSH keys..."

VAULT_KEY="$DOTFILES_DIR/.ssh/id_ed25519.vault"
PUB_KEY="$DOTFILES_DIR/.ssh/id_ed25519.pub"
DEST_DIR="$HOME_DIR/.ssh"
DEST_KEY="$DEST_DIR/id_ed25519"

mkdir -p "$DEST_DIR"
chmod 700 "$DEST_DIR"

# Skip if keys already exist at destination
if [ -f "$DEST_KEY" ]; then
    echo -e "${YELLOW}→${NC} SSH key already exists at $DEST_KEY, skipping"
else
    if [ ! -f "$VAULT_KEY" ]; then
        echo -e "${RED}✗${NC} Vault-encrypted key not found at $VAULT_KEY"
        echo "  Skipping SSH key setup."
        return 0 2>/dev/null || exit 0
    fi

    if ! command -v ansible-vault &>/dev/null; then
        echo -e "${RED}✗${NC} ansible-vault not found. Install ansible first:"
        if is_macos; then
            echo "  brew install ansible"
        else
            echo "  sudo apt install ansible"
        fi
        return 0 2>/dev/null || exit 0
    fi

    # Copy encrypted key to destination
    cp "$VAULT_KEY" "$DEST_KEY"
    chmod 600 "$DEST_KEY"

    # Prompt for vault password and decrypt in place
    echo -e "${BLUE}Decrypting SSH private key (ansible-vault)...${NC}"
    ansible-vault decrypt "$DEST_KEY"

    echo -e "${GREEN}✓${NC} SSH private key decrypted and installed"
fi

# Install public key
if [ -f "$PUB_KEY" ] && [ ! -f "$DEST_KEY.pub" ]; then
    cp "$PUB_KEY" "$DEST_KEY.pub"
    chmod 644 "$DEST_KEY.pub"
    echo -e "${GREEN}✓${NC} SSH public key installed"
else
    echo -e "${YELLOW}→${NC} SSH public key already exists, skipping"
fi

# Set up authorized_keys
if [ -f "$DEST_KEY.pub" ]; then
    touch "$DEST_DIR/authorized_keys"
    chmod 600 "$DEST_DIR/authorized_keys"
    if ! grep -qf "$DEST_KEY.pub" "$DEST_DIR/authorized_keys" 2>/dev/null; then
        cat "$DEST_KEY.pub" >> "$DEST_DIR/authorized_keys"
        echo -e "${GREEN}✓${NC} Added public key to authorized_keys"
    fi
fi
