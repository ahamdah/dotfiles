# Ahmad's Dotfiles

> **One command to get your full dev environment on a new machine.**

```bash
git clone https://github.com/ahamdah/dotfiles.git ~/dotfiles
cd ~/dotfiles && make install
```

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS | ✅ Full support (Homebrew) |
| Ubuntu / Debian | ✅ Full support (apt + cargo) |
| WSL2 (Windows) | ✅ Full support |

---

## What Gets Installed

| Tool | Purpose |
|------|---------|
| [Zsh](https://www.zsh.org) + [Oh My Zsh](https://ohmyz.sh) | Shell |
| [Starship](https://starship.rs) | Cross-shell prompt |
| [eza](https://github.com/eza-community/eza) | Modern `ls` with icons |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` with syntax highlighting |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl+R, Ctrl+T) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` with frecency |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal Git UI |
| [delta](https://github.com/dandavison/delta) | Beautiful git diffs |
| [gh](https://cli.github.com) | GitHub CLI |
| [tmux](https://github.com/tmux/tmux) + TPM | Terminal multiplexer |
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager |
| [Rust](https://rustup.rs) | Cargo + toolchain |

---

## Quick Commands

```bash
make install      # Install everything + symlink dotfiles
make link         # Symlink dotfiles only (no package installs)
make update       # Pull latest + re-link
make check        # Validate all shell scripts and JSON configs
make macos        # Apply macOS system defaults (macOS only)
make brew-bundle  # Install all apps from Brewfile (macOS only)
make clean        # Remove all symlinks
```

---

## Repo Structure

```
dotfiles/
├── shell/
│   ├── .zshrc              ← Entry point (sources modules)
│   ├── .zshenv             ← Non-interactive PATH (cron, scripts)
│   ├── exports.zsh         ← PATH & environment variables
│   ├── aliases.zsh         ← Aliases (OS-aware)
│   ├── plugins.zsh         ← Oh My Zsh plugins & theme
│   ├── keybindings.zsh     ← bindkey & ZLE widgets
│   ├── functions.zsh       ← mkcd, extract, fcd, serve, fs, fo…
│   └── .tmux.conf          ← Tmux config (Catppuccin theme)
│
├── config/
│   ├── starship.toml       ← Starship prompt
│   ├── nvim/               ← Neovim (lazy.nvim + LSP + Catppuccin)
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/     ← options, keymaps, autocmds
│   │       └── plugins/    ← all plugin specs
│   ├── git/
│   │   ├── .gitconfig      ← Global git config + aliases
│   │   └── .gitignore_global
│   ├── vscode/
│   │   ├── settings.json
│   │   ├── keybindings.json
│   │   └── install-extensions.sh ← portable extension installer
│   └── windows-terminal/
│       └── settings.json
│
├── scripts/
│   ├── setup.sh            ← Full installer (macOS + Linux)
│   ├── link.sh             ← Symlinks only
│   ├── macos.sh            ← macOS system defaults
│   └── brew-bundle/
│       └── Brewfile        ← All Homebrew apps
│
├── .github/
│   └── workflows/
│       └── check.yml       ← CI: validates all scripts on push
├── Makefile                ← Entry point
├── Dockerfile              ← Ubuntu container for testing
└── README.md
```

---

## Symlinks Created

| Dotfile | Links to |
|---------|----------|
| `~/.zshrc` | `shell/.zshrc` |
| `~/.tmux.conf` | `shell/.tmux.conf` |
| `~/.config/starship.toml` | `config/starship.toml` |
| `~/.gitconfig` | `config/git/.gitconfig` |
| `~/.gitignore_global` | `config/git/.gitignore_global` |
| VS Code `settings.json` | `config/vscode/settings.json` |
| VS Code `keybindings.json` | `config/vscode/keybindings.json` |

---

## First-time Git Config

After running `make install`, edit your git identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

---

## Tmux Quick Reference

| Action | Keybinding |
|--------|-----------|
| Prefix | `Ctrl+a` |
| Vertical split | `Prefix + \|` |
| Horizontal split | `Prefix + -` |
| Navigate panes | `Prefix + h/j/k/l` |
| Navigate windows | `Prefix + m/n` |
| Install plugins | `Prefix + I` |
| Reload config | `Prefix + r` |
| Copy mode | `Prefix + Enter` |
| Copy selection | `v` then `y` |
