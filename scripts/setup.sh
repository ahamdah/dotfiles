#!/usr/bin/env bash
# =============================================================================
# setup.sh — Install all tools and link dotfiles
# Supports: macOS (via Homebrew) and Linux/Ubuntu (via apt-get)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log_step()    { echo -e "\n${CYAN}${BOLD}▶ $1${RESET}"; }
log_info()    { echo -e "  ${BLUE}→${RESET} $1"; }
log_success() { echo -e "  ${GREEN}✓${RESET} $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${RESET} $1"; }
log_error()   { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

# ── Detect OS ─────────────────────────────────────────────────────────────────
OS="$(uname -s)"
IS_WSL=false
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

if [[ "$OS" == "Darwin" ]]; then
  PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
  PLATFORM="linux"
else
  log_error "Unsupported OS: $OS"
fi

log_step "Detected platform: $PLATFORM (WSL: $IS_WSL)"

# =============================================================================
# Package management helpers
# =============================================================================

brew_install() {
  local pkg="$1"
  if brew list --formula "$pkg" &>/dev/null; then
    log_warn "$pkg already installed"
  else
    log_info "Installing $pkg..."
    brew install "$pkg"
    log_success "$pkg installed"
  fi
}

apt_install() {
  local pkg="$1"
  if dpkg -s "$pkg" &>/dev/null 2>&1; then
    log_warn "$pkg already installed"
  else
    log_info "Installing $pkg..."
    sudo apt-get install -y -qq "$pkg"
    log_success "$pkg installed"
  fi
}

cargo_install() {
  local pkg="$1"
  if command -v "$pkg" &>/dev/null; then
    log_warn "$pkg already installed"
  else
    log_info "Building $pkg from source (cargo)..."
    cargo install "$pkg"
    log_success "$pkg installed"
  fi
}

# =============================================================================
# macOS setup
# =============================================================================

setup_macos() {
  log_step "macOS Setup"

  # Homebrew
  if ! command -v brew &>/dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    log_success "Homebrew installed"
  else
    log_warn "Homebrew already installed"
  fi

  log_step "Installing packages via Homebrew"

  # Core tools
  for pkg in git curl wget zsh tmux neovim jq rsync; do
    brew_install "$pkg"
  done

  # Modern CLI tools
  for pkg in eza bat ripgrep fd fzf zoxide starship lazygit gh delta; do
    brew_install "$pkg"
  done

  # Fonts (for Nerd Font icons)
  if ! brew list --cask font-cascadia-code-nf &>/dev/null 2>&1; then
    log_info "Installing Cascadia Code NF font..."
    brew install --cask font-cascadia-code-nf || log_warn "Font install skipped"
  else
    log_warn "Cascadia Code NF already installed"
  fi

  # Rust (for cargo-based tools)
  if ! command -v cargo &>/dev/null; then
    log_info "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    log_warn "Rust already installed"
  fi

  # nvm
  if [[ ! -d "$HOME/.nvm" ]]; then
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    log_success "nvm installed"
  else
    log_warn "nvm already installed"
  fi
}

# =============================================================================
# Linux setup
# =============================================================================

setup_linux() {
  log_step "Linux Setup"

  log_info "Updating package lists..."
  sudo apt-get update -qq

  # Core tools
  log_step "Installing core packages"
  for pkg in git curl wget zsh tmux vim neovim jq rsync unzip build-essential fonts-powerline fuse libfuse2; do
    apt_install "$pkg"
  done

  # Starship
  if ! command -v starship &>/dev/null; then
    log_info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    log_success "Starship installed"
  else
    log_warn "Starship already installed"
  fi

  # Rust (needed for eza, bat, ripgrep, delta)
  if ! command -v cargo &>/dev/null; then
    log_info "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    log_success "Rust installed"
  else
    log_warn "Rust already installed"
    source "$HOME/.cargo/env" 2>/dev/null || true
  fi

  log_step "Installing Rust-based CLI tools"
  cargo_install eza
  cargo_install bat
  cargo_install rg        # ripgrep
  cargo_install delta     # git-delta

  # fzf
  if [[ ! -d "$HOME/.fzf" ]]; then
    log_info "Installing fzf..."
    git clone --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
    log_success "fzf installed"
  else
    log_warn "fzf already installed"
  fi

  # zoxide
  if ! command -v zoxide &>/dev/null; then
    log_info "Installing zoxide..."
    curl -sS https://install.zoxide.dev | sh
    log_success "zoxide installed"
  else
    log_warn "zoxide already installed"
  fi

  # fd
  if ! command -v fd &>/dev/null; then
    log_info "Installing fd..."
    apt_install fd-find
    # Debian/Ubuntu names it fdfind
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true
  fi

  # GitHub CLI
  if ! command -v gh &>/dev/null; then
    log_info "Installing GitHub CLI..."
    if ! apt_install gh 2>/dev/null; then
      # Fallback: install via official script
      curl -sS https://webi.sh/gh | sh
    fi
  else
    log_warn "gh already installed"
  fi

  # lazygit
  if ! command -v lazygit &>/dev/null; then
    log_info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -sS "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
      | grep '"tag_name":' | cut -d'"' -f4 | sed 's/^v//')
    curl -sSLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    mkdir -p "$HOME/.local/bin"
    mv /tmp/lazygit "$HOME/.local/bin/lazygit"
    rm -f /tmp/lazygit.tar.gz
    log_success "lazygit installed"
  else
    log_warn "lazygit already installed"
  fi

  # nvm
  if [[ ! -d "$HOME/.nvm" ]]; then
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    log_success "nvm installed"
  else
    log_warn "nvm already installed"
  fi
}

# =============================================================================
# Common setup (runs on both platforms)
# =============================================================================

setup_oh_my_zsh() {
  log_step "Oh My Zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_warn "Oh My Zsh already installed"
    return
  fi
  log_info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log_success "Oh My Zsh installed"
}

setup_zsh_plugins() {
  log_step "Zsh Plugins"
  local zsh_custom="$HOME/.oh-my-zsh/custom"

  if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "$zsh_custom/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
  else
    log_warn "zsh-syntax-highlighting already installed"
  fi

  if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
    log_info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
      "$zsh_custom/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions installed"
  else
    log_warn "zsh-autosuggestions already installed"
  fi
}

setup_tmux_plugins() {
  log_step "Tmux Plugins (TPM)"
  local tmux_plugins="$HOME/.tmux/plugins"
  mkdir -p "$tmux_plugins"

  if [[ ! -d "$tmux_plugins/tpm" ]]; then
    log_info "Installing TPM..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tmux_plugins/tpm"
    log_success "TPM installed"
  else
    log_warn "TPM already installed"
  fi
}

set_default_shell() {
  log_step "Default Shell"
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "$SHELL" == "$zsh_path" ]]; then
    log_warn "zsh is already the default shell"
    return
  fi

  if grep -q "$zsh_path" /etc/shells; then
    log_info "Setting zsh as default shell..."
    chsh -s "$zsh_path"
    log_success "Default shell changed to zsh"
  else
    log_warn "$zsh_path not in /etc/shells — add it manually then run: chsh -s $zsh_path"
  fi
}

# =============================================================================
# Main
# =============================================================================

main() {
  echo -e "\n${BOLD}╔══════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}║     Dotfiles Setup — $PLATFORM        ${RESET}"
  echo -e "${BOLD}╚══════════════════════════════════════╝${RESET}\n"

  # Platform-specific installs
  [[ "$PLATFORM" == "macos" ]] && setup_macos
  [[ "$PLATFORM" == "linux" ]] && setup_linux

  # Common
  setup_oh_my_zsh
  setup_zsh_plugins
  setup_tmux_plugins
  set_default_shell

  # Symlinks
  log_step "Creating symlinks"
  bash "$SCRIPT_DIR/link.sh"

  echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════╗${RESET}"
  echo -e "${GREEN}${BOLD}║         Setup Complete! 🎉            ${RESET}"
  echo -e "${GREEN}${BOLD}╚══════════════════════════════════════╝${RESET}\n"
  echo "  Next steps:"
  echo "  1. exec zsh                         → reload shell"
  echo "  2. Edit ~/.gitconfig                → add your name & email"
  echo "  3. tmux, then prefix+I (Ctrl+a, I)  → install tmux plugins"
  echo ""
}

main "$@"
