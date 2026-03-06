#!/usr/bin/env bash
# =============================================================================
# link.sh — Create symlinks from dotfiles repo to home directory
#
# Usage:
#   bash scripts/link.sh            # interactive (asks before overwriting)
#   bash scripts/link.sh --force    # overwrite existing files/links silently
# =============================================================================
set -euo pipefail

FORCE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

log_info()    { echo -e "${BLUE}  →${RESET} $1"; }
log_success() { echo -e "${GREEN}  ✓${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}  ⚠${RESET} $1"; }
log_error()   { echo -e "${RED}  ✗${RESET} $1"; }

# ── Helper: create symlink ────────────────────────────────────────────────────
link() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    log_error "Source not found: $src"
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log_warn "Already linked: $dst"
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ "$FORCE" == "--force" ]]; then
      rm -rf "$dst"
    else
      local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
      log_warn "Backing up existing: $dst → $backup"
      mv "$dst" "$backup"
    fi
  fi

  ln -sf "$src" "$dst"
  log_success "Linked: ${dst/$HOME/\~} → ${src/$DOTFILES_DIR/dotfiles}"
}

# ── Ensure third-party Zsh plugins are installed ─────────────────────────────
# zsh-autosuggestions and zsh-syntax-highlighting are NOT bundled with OMZ.
# They must be cloned into $ZSH_CUSTOM/plugins manually.
ensure_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ ! -d "$zsh_custom/plugins" ]]; then
    log_warn "Oh My Zsh not found at $zsh_custom — skipping plugin install"
    return
  fi

  local plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
  )

  for entry in "${plugins[@]}"; do
    local name="${entry%%|*}"
    local url="${entry##*|}"
    local dir="$zsh_custom/plugins/$name"

    if [[ -d "$dir" ]]; then
      log_warn "Already installed: $name"
    else
      log_info "Cloning $name..."
      git clone --depth=1 "$url" "$dir"
      log_success "Installed: $name"
    fi
  done
}

# ── Symlinks ─────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}=== Dotfiles Symlink Setup ===${RESET}\n"

ensure_zsh_plugins

# Shell
link "$DOTFILES_DIR/shell/.zshenv"    "$HOME/.zshenv"
link "$DOTFILES_DIR/shell/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES_DIR/shell/exports.zsh"     "$HOME/.config/zsh/exports.zsh"
link "$DOTFILES_DIR/shell/aliases.zsh"     "$HOME/.config/zsh/aliases.zsh"
link "$DOTFILES_DIR/shell/plugins.zsh"     "$HOME/.config/zsh/plugins.zsh"
link "$DOTFILES_DIR/shell/keybindings.zsh" "$HOME/.config/zsh/keybindings.zsh"
link "$DOTFILES_DIR/shell/functions.zsh"   "$HOME/.config/zsh/functions.zsh"
link "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"

# Starship
link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# Git
link "$DOTFILES_DIR/config/git/.gitconfig"       "$HOME/.gitconfig"
link "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"

# Neovim
link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# VS Code — path differs by OS
if [[ "$(uname)" == "Darwin" ]]; then
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  # WSL: point to Windows-side VS Code config
  WIN_HOME="$(wslpath "$(wslvar USERPROFILE 2>/dev/null || echo 'C:\Users\user')")"
  VSCODE_USER_DIR="$WIN_HOME/AppData/Roaming/Code/User"
else
  VSCODE_USER_DIR="$HOME/.config/Code/User"
fi

if [[ -d "$(dirname "$VSCODE_USER_DIR")" || "$FORCE" == "--force" ]]; then
  link "$DOTFILES_DIR/config/vscode/settings.json"    "$VSCODE_USER_DIR/settings.json"
  link "$DOTFILES_DIR/config/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
else
  log_warn "VS Code dir not found, skipping: $VSCODE_USER_DIR"
fi

echo -e "\n${GREEN}${BOLD}✓ Symlinks created.${RESET}"
echo -e "  Run ${BOLD}exec zsh${RESET} to reload your shell.\n"
