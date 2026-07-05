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
  if [[ -f "$f" ]]; then
    source "$f"
  else
    echo "[zshrc] Warning: missing $f"
  fi
}

_source exports.zsh     # PATH, env vars, tool exports

# Extra completions (e.g. Homebrew) — must be on FPATH before OMZ runs compinit
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

_source plugins.zsh     # OMZ theme, plugin list, source OMZ (runs compinit)
_source aliases.zsh     # all aliases (OS-aware)
_source keybindings.zsh # bindkey + ZLE widgets
_source functions.zsh   # shell functions (mkcd, extract, serve, etc.)

# ── Smart cd: zoxide ─────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Completions: Oh My Zsh already runs compinit (sourced in plugins.zsh);
# running it again here would double zsh startup cost.
