#!/usr/bin/env zsh
# =============================================================================
# .zshrc — Entry point. Sources modular config files.
# =============================================================================

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

# ── Prompt: Starship ─────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

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
