#!/usr/bin/env zsh
# =============================================================================
# exports.zsh — Environment variables and PATH configuration
# =============================================================================

# ── Language & Locale ─────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ── Default Programs ──────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# ── PATH ──────────────────────────────────────────────────────────────────────
# Build PATH in one place, ordered by priority (highest first)
export PATH="\
$HOME/.local/bin:\
$HOME/bin:\
$HOME/.cargo/bin:\
/usr/local/bin:\
/usr/bin:\
/bin:\
$PATH"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# ── nvm (Node Version Manager) ────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ── fzf ───────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="
  --height 50%
  --layout=reverse
  --border=rounded
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"
# Use fd for fzf file search if available
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
fi

# ── Bat (better cat) ──────────────────────────────────────────────────────────
export BAT_THEME="Catppuccin Mocha"

# ── Less ──────────────────────────────────────────────────────────────────────
export LESS="-RFXi"
export LESSHISTFILE="$HOME/.local/state/less/history"

# ── Antigravity ───────────────────────────────────────────────────────────────
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && \
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
