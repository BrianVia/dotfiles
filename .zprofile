# Amazon Q pre block. Keep at the top of this file.
if [[ "$OSTYPE" == darwin* ]]; then
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
fi

# Homebrew (macOS only)
if [[ "$OSTYPE" == darwin* ]] && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Amazon Q post block. Keep at the bottom of this file.
if [[ "$OSTYPE" == darwin* ]]; then
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
fi

# Created by `pipx` on 2025-02-10 16:37:36
export PATH="$PATH:$HOME/.local/bin"
