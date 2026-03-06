#!/usr/bin/env bash
# =============================================================================
# update.sh — Update all tools and dotfiles
# Usage: make update  OR  bash scripts/update.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

log_step() { echo -e "\n${CYAN}${BOLD}▶ $1${RESET}"; }
log_ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
log_skip() { echo -e "  ${YELLOW}⚠${RESET} $1"; }

OS="$(uname -s)"

echo -e "\n${BOLD}╔══════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║         Dotfiles Update 🔄            ${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════╝${RESET}"

# ── Dotfiles: pull latest ─────────────────────────────────────────────────────
log_step "Dotfiles"
cd "$DOTFILES_DIR"
git pull --rebase --autostash
log_ok "Dotfiles up to date"
bash "$SCRIPT_DIR/link.sh" --force
log_ok "Symlinks refreshed"

# ── Homebrew (macOS) ──────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]] && command -v brew &>/dev/null; then
  log_step "Homebrew"
  brew update
  brew upgrade
  brew autoremove
  brew cleanup --prune=7
  log_ok "Homebrew packages upgraded"
fi

# ── apt (Linux) ───────────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]] && command -v apt-get &>/dev/null; then
  log_step "apt packages"
  sudo apt-get update -qq && sudo apt-get upgrade -y -qq
  log_ok "apt packages upgraded"
fi

# ── Rust ──────────────────────────────────────────────────────────────────────
if command -v rustup &>/dev/null; then
  log_step "Rust toolchain"
  rustup update stable
  log_ok "Rust updated"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  log_step "Oh My Zsh"
  env ZSH="$HOME/.oh-my-zsh" zsh "$HOME/.oh-my-zsh/tools/upgrade.sh" --unattended 2>/dev/null \
    && log_ok "Oh My Zsh updated" || log_skip "Oh My Zsh update skipped"
fi

# ── Zsh plugins ───────────────────────────────────────────────────────────────
log_step "Zsh plugins"
for plugin_dir in "$HOME/.oh-my-zsh/custom/plugins"/*/; do
  if [[ -d "$plugin_dir/.git" ]]; then
    plugin_name=$(basename "$plugin_dir")
    git -C "$plugin_dir" pull --rebase --autostash -q \
      && log_ok "$plugin_name updated" || log_skip "$plugin_name: up to date"
  fi
done

# ── Tmux plugins (TPM) ────────────────────────────────────────────────────────
if [[ -f "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]]; then
  log_step "Tmux plugins"
  "$HOME/.tmux/plugins/tpm/bin/update_plugins" all 2>/dev/null \
    && log_ok "Tmux plugins updated" || log_skip "Tmux not running — run prefix+U inside tmux"
fi

# ── nvm / Node ────────────────────────────────────────────────────────────────
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  log_step "nvm + Node"
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh"
  nvm install --lts --reinstall-packages-from=current 2>/dev/null \
    && log_ok "Node LTS updated ($(node --version))" \
    || log_skip "Node already at latest LTS"
fi

# ── Neovim plugins (lazy.nvim) ────────────────────────────────────────────────
if command -v nvim &>/dev/null; then
  log_step "Neovim plugins"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null \
    && log_ok "Neovim plugins synced" || log_skip "Neovim plugin sync skipped"
fi

# ── GitHub CLI ────────────────────────────────────────────────────────────────
if command -v gh &>/dev/null && [[ "$OS" != "Darwin" ]]; then
  log_step "GitHub CLI"
  gh extension upgrade --all 2>/dev/null && log_ok "gh extensions updated" || true
fi

echo -e "\n${GREEN}${BOLD}✓ Everything is up to date!${RESET}"
echo "  Run ${BOLD}exec zsh${RESET} to reload your shell.\n"
