# Amazon Q pre block. Keep at the top of this file.
# macOS-specific Amazon Q
if [[ "$OSTYPE" == darwin* ]]; then
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
fi
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

#Path to your oh-my-zsh installation.

# Use $HOME instead of hard-coded paths
export HOME_DIR=$HOME

# Detect if running on WSL2
if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    export IS_WSL2=true
else
    export IS_WSL2=false
fi

# Unlock keychain for SSH sessions (needed for Claude Code) — macOS only
if [[ "$OSTYPE" == darwin* ]] && [[ -n "$SSH_CONNECTION" ]]; then
    security unlock-keychain ~/Library/Keychains/login.keychain-db 2>/dev/null
fi

export ZSH="$HOME_DIR/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(zsh-autosuggestions git github)

zstyle :omz:plugins:ssh-agent identities id_ed25519

source $ZSH/oh-my-zsh.sh
source $HOME/.development_aliases
source $HOME/.profile
source $HOME/.personal_aliases
source $HOME/.secret_env_vars
export PATH="$HOME/scripts:$PATH"
export ENABLE_BACKGROUND_TASKS=1 ## Claude Code Usage
autoload -U add-zsh-hook

# bun completions
[ -s "$HOME_DIR/.bun/_bun" ] && source "$HOME_DIR/.bun/_bun"

# bun
export BUN_INSTALL="$HOME_DIR/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export GITHUB_ACTOR="BrianVia"
# eval "$(starship init zsh)"

# sst
export PATH=$HOME/.sst/bin:$PATH

[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# AWS SSO Profile Switcher Function
sso() {
    list_profiles() {
        touch ~/.aws/config
        grep -v "^#" ~/.aws/config | grep -o '\[profile[^][]*]' | cut -d "[" -f2 | cut -d "]" -f1 | cut -d " " -f2
    }
    echo "Here's a list of available profiles from ~/.aws/config:"
    instances=($(list_profiles)) 
    len=${#instances[@]} 
    for ((i=1; i<=$len; i+=1 )); do
        echo "$((i)): ${instances[$i]}"
    done
    echo -e "\nPlease choose an profile by number:"
    read INSTANCE_NUMBER
    index=$((INSTANCE_NUMBER)) 
    export AWS_PROFILE=${instances[$index]} 
    echo "Using AWS PROFILE ($AWS_PROFILE)"
    if ! aws sts get-caller-identity --no-cli-pager; then
        echo "Invalid credentials or another error occurred. Attempting to login with SSO..."
        aws sso login
    fi
}

# Java JDK for Android development (macOS only — requires brew)
if [[ "$OSTYPE" == darwin* ]] && command -v brew &>/dev/null; then
    export JAVA_HOME=$(brew --prefix openjdk@17)
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Android SDK — platform-aware paths
if [[ "$OSTYPE" == darwin* ]]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
else
    export ANDROID_HOME=$HOME/Android/Sdk
fi
if [ -d "$ANDROID_HOME" ]; then
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# Amazon Q post block. Keep at the bottom of this file.
# macOS-specific Amazon Q
if [[ "$OSTYPE" == darwin* ]]; then
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
fi

# Created by `pipx` on 2025-02-10 16:37:36
export PATH="$PATH:$HOME/.local/bin"
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=~/.npm-global/bin:$PATH

# mkdir and cd into directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

alias claude="$HOME/.claude/local/claude"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

