#!/usr/bin/env zsh
# =============================================================================
# .zshrc — Entry point. Sources modular config files.
# =============================================================================


export JAVA_HOME=/opt/homebrew/opt/openjdk@21
export PATH=$JAVA_HOME/bin:$PATH
export KUBECONFIG=~/.kube/rabtly-k3s.yaml

export CLOUDFRONT_DIST_ID=EC47E1CAW8G7J


# Guard: only run in interactive shells
[[ -o interactive ]] || return

# ── Source modules ────────────────────────────────────────────────────────────
ZDOTDIR_CUSTOM="${ZDOTDIR_CUSTOM:-$HOME}"

# Resolve the dotfiles directory (follow symlink if needed)
_zshrc_path="${${(%):-%N}:A}"
_zshrc_dir="${_zshrc_path:h}"

_source() {
  local f="$_zshrc_dir/$1"
  [[ -f "$f" ]] && source "$f" || echo "[zshrc] Warning: missing $f"
}

_source exports.zsh     # PATH, env vars, tool exports
_source plugins.zsh     # OMZ theme, plugin list, source OMZ
_source aliases.zsh     # all aliases (OS-aware)
_source keybindings.zsh # bindkey + ZLE widgets
_source functions.zsh   # shell functions (mkcd, extract, serve, etc.)

# ── Smart cd: zoxide ─────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ── Completions ───────────────────────────────────────────────────────────────
# Load any extra completions (e.g. from Homebrew on macOS)
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

autoload -Uz compinit
# Only rebuild completion cache once per day (check mtime via find)
if find "${ZDOTDIR:-$HOME}/.zcompdump" -mmin +1440 &>/dev/null 2>&1; then
  compinit
else
  compinit -C
fi

# Added by Antigravity
export PATH="/Users/ahamdah/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/ahamdah/.antigravity/antigravity/bin:$PATH"

# Android SDK (added for Rabtly mobile)
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/27.3.13750724

# bun completions
[ -s "/Users/ahamdah/.bun/_bun" ] && source "/Users/ahamdah/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Claude Code
alias cc='claude --dangerously-skip-permissions'
