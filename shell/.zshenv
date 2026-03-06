#!/usr/bin/env zsh
# =============================================================================
# .zshenv — Sourced for ALL shells (interactive, non-interactive, scripts)
# Keep this MINIMAL: only what must be available everywhere.
# Heavy config (aliases, plugins, prompt) goes in .zshrc.
# =============================================================================

# ── PATH ──────────────────────────────────────────────────────────────────────
# These need to be available even in non-interactive shells (cron, scripts, etc.)
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Homebrew (macOS) — set early so scripts can call brew
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── Core env vars ─────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
