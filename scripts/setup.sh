#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

echo "=== Dotfiles Setup Script ==="
echo "Installing development environment..."

update_packages() {
    echo "Updating package lists..."
    apt-get update -qq
}

install_basic_tools() {
    echo "Installing basic tools..."
    apt-get install -y -qq \
        curl \
        wget \
        git \
        vim \
        zsh \
        tmux \
        fonts-powerline \
        build-essential \
        unzip \
        jq \
        rsync \
        fuse \
        libfuse2
}

install_starship() {
    echo "Installing Starship prompt..."
    if command -v starship &> /dev/null; then
        echo "Starship already installed"
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
}

install_rust_tools() {
    echo "Installing Rust tools (eza, bat, eza)..."

    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    if command -v eza &> /dev/null; then
        echo "eza already installed"
    else
        cargo install eza
    fi

    if command -v bat &> /dev/null; then
        echo "bat already installed"
    else
        cargo install bat
    fi

    if command -v ripgrep &> /dev/null; then
        echo "ripgrep already installed"
    else
        cargo install ripgrep
    fi
}

install_fzf() {
    echo "Installing fzf..."
    if [[ -d "$HOME/.fzf" ]]; then
        echo "fzf already installed"
    else
        git clone --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all --no-bash --no-fish
    fi
}

install_zoxide() {
    echo "Installing zoxide..."
    if command -v zoxide &> /dev/null; then
        echo "zoxide already installed"
    else
        curl -sS https://install.zoxide.dev | sh
    fi
}

install_github_cli() {
    echo "Installing GitHub CLI..."
    if command -v gh &> /dev/null; then
        echo "gh already installed"
    else
        apt-get install -y -qq gh
    fi
}

install_lazygit() {
    echo "Installing lazygit..."
    if command -v lazygit &> /dev/null; then
        echo "lazygit already installed"
    else
        LAZYGIT_VERSION=$(curl -sS "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -o '"tag_name": "*[^"]*' | cut -d'"' -f4)
        LAZYGIT_VERSION="${LAZYGIT_VERSION#v}"
        curl -sSLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        mv /tmp/lazygit "$HOME/.local/bin/lazygit"
        rm /tmp/lazygit.tar.gz
    fi
}

install_nvm() {
    echo "Installing nvm..."
    if [[ -d "$HOME/.nvm" ]]; then
        echo "nvm already installed"
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
}

install_oh_my_zsh() {
    echo "Installing Oh-My-Zsh..."
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Oh-My-Zsh already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

install_zsh_plugins() {
    echo "Installing Zsh plugins..."

    local zsh_custom="$HOME/.oh-my-zsh/custom"

    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
    fi

    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/plugins/zsh-autosuggestions"
    fi
}

install_tmux_plugins() {
    echo "Installing Tmux plugins..."

    local tmux_plugins="$HOME/.tmux/plugins"

    mkdir -p "$tmux_plugins"

    if [[ ! -d "$tmux_plugins/tpm" ]]; then
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$tmux_plugins/tpm"
    fi
}

setup_shell_config() {
    echo "Setting up shell configuration..."

    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
    fi

    ln -sf "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"

    if [[ -f "$HOME/.tmux.conf" ]]; then
        cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d)"
    fi

    ln -sf "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
}

setup_vscode() {
    echo "Setting up VS Code configuration..."

    local vscode_dir="$HOME/.config/Code/User"
    mkdir -p "$vscode_dir"

    if [[ -d "$DOTFILES_DIR/config/vscode" ]]; then
        for file in "$DOTFILES_DIR/config/vscode"/*; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                ln -sf "$file" "$vscode_dir/$filename"
            fi
        done
    fi
}

install_docker_dependencies() {
    echo "Installing Docker dependencies..."
    apt-get install -y -qq \
        docker.io \
        docker-compose \
        || echo "Docker installation skipped (may require additional setup)"
}

main() {
    update_packages
    install_basic_tools
    install_starship
    install_rust_tools
    install_fzf
    install_zoxide
    install_github_cli
    install_lazygit
    install_nvm
    install_oh_my_zsh
    install_zsh_plugins
    install_tmux_plugins
    setup_shell_config
    setup_vscode
    install_docker_dependencies

    echo ""
    echo "=== Setup Complete ==="
    echo "Please restart your shell or run: exec zsh"
    echo ""
    echo "To start tmux: tmux"
    echo "To install tmux plugins: prefix + I (Ctrl-a then I)"
    echo ""
    echo "Installed tools:"
    echo "  - Starship prompt (run 'starship init zsh' to enable)"
    echo "  - eza (modern ls)"
    echo "  - bat (modern cat)"
    echo "  - ripgrep (fast grep)"
    echo "  - fzf (fuzzy finder)"
    echo "  - zoxide (smart cd)"
    echo "  - GitHub CLI (gh)"
    echo "  - lazygit (git TUI)"
    echo "  - nvm (Node version manager)"
}

main "$@"
