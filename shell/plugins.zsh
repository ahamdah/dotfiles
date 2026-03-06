#!/usr/bin/env zsh
# =============================================================================
# plugins.zsh — Oh My Zsh theme and plugin configuration
# =============================================================================

# ── Theme ─────────────────────────────────────────────────────────────────────
# Using Starship instead of an OMZ theme for cross-shell consistency.
# Set to empty string to disable OMZ's theme (Starship handles the prompt).
ZSH_THEME=""

# ── OMZ Behaviour ────────────────────────────────────────────────────────────
zstyle ':omz:update' mode reminder    # remind to update, don't auto-update
DISABLE_LS_COLORS="true"              # we use eza which handles its own colors
DISABLE_AUTO_TITLE="true"             # tmux/terminal handles tab titles

# ── Plugins ───────────────────────────────────────────────────────────────────
plugins=(
  git                      # git aliases and completions
  sudo                     # press ESC twice to prefix last command with sudo
  web-search               # search from terminal: `google <query>`
  copyfile                 # `copyfile <file>` copies contents to clipboard
  copybuffer               # Ctrl+O copies current buffer to clipboard
  dirhistory               # Alt+Left/Right navigate directory history
  history                  # `h` for history, `hsi` for history search
  tmux                     # tmux aliases and auto-start
  vscode                   # `vsc` to open VS Code
  kubectl                  # kubectl autocomplete + aliases
  zsh-syntax-highlighting  # command syntax coloring (must be near last)
  zsh-autosuggestions      # fish-like history suggestions
)

# ── Source OMZ ───────────────────────────────────────────────────────────────
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ── Autosuggestions style ────────────────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ── Syntax highlighting ───────────────────────────────────────────────────────
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
