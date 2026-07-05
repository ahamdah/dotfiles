# Ahmad's Dotfiles

> **One command to get your full dev environment on a new machine.**

```bash
git clone https://github.com/AhmdFahad/dotfiles.git ~/dotfiles
cd ~/dotfiles && make install
```

![CI](https://github.com/AhmdFahad/dotfiles/actions/workflows/check.yml/badge.svg)

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
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like history suggestions |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Command syntax coloring |
| [Starship](https://starship.rs) | Installed but unused — zsh prompt is the custom OMZ `gruvbox` theme |
| [Neovim](https://neovim.io) + lazy.nvim | Editor with LSP, Treesitter, completion |
| [eza](https://github.com/eza-community/eza) | Modern `ls` with icons |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` with syntax highlighting |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement (`rg`) |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl+R, Ctrl+T, Alt+C) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` with frecency |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal Git UI (`lg`) |
| [delta](https://github.com/dandavison/delta) | Beautiful git diffs |
| [gh](https://cli.github.com) | GitHub CLI |
| [tmux](https://github.com/tmux/tmux) + TPM | Terminal multiplexer |
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager |
| [Rust](https://rustup.rs) | Cargo + toolchain |

> **Note:** `zsh-autosuggestions` and `zsh-syntax-highlighting` are **not** bundled with Oh My Zsh.
> `make link` clones them automatically if missing.

---

## Quick Commands

```bash
make install      # Install all tools + symlink dotfiles
make link         # Symlinks only (also installs zsh plugins if missing)
make update       # Update all tools + pull latest dotfiles
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
│   ├── plugins.zsh         ← Oh My Zsh plugins & theme (ZSH_THEME="gruvbox")
│   ├── gruvbox.zsh-theme   ← Custom Gruvbox Dark OMZ prompt
│   ├── keybindings.zsh     ← bindkey & ZLE widgets
│   ├── functions.zsh       ← mkcd, extract, fcd, serve, fs, fo…
│   └── .tmux.conf          ← Tmux config (Catppuccin theme)
│
├── config/
│   ├── starship.toml       ← Starship prompt config (unused, kept for reference)
│   ├── iterm2/
│   │   ├── DynamicProfiles/gruvbox.json ← iTerm2 Gruvbox Dark profile
│   │   └── preferences/com.googlecode.iterm2.plist ← Full iTerm2 settings (General, Key Mappings, …)
│   ├── nvim/               ← Neovim (lazy.nvim + LSP + Catppuccin)
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/     ← options, keymaps, autocmds
│   │       └── plugins/    ← all plugin specs
│   ├── git/
│   │   ├── .gitconfig      ← Global git config + aliases + delta
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
│   ├── link.sh             ← Symlinks + zsh plugin auto-install
│   ├── update.sh           ← Update all tools in one command
│   ├── macos.sh            ← macOS system defaults
│   └── brew-bundle/
│       └── Brewfile        ← Full macOS app manifest
│
├── .github/
│   └── workflows/
│       └── check.yml       ← CI: validates scripts on every push
├── Makefile                ← Entry point
├── Dockerfile              ← Ubuntu container for testing
└── README.md
```

---

## Symlinks Created by `make link`

| Symlink | Points to |
|---------|-----------|
| `~/.zshenv` | `shell/.zshenv` |
| `~/.zshrc` | `shell/.zshrc` |
| `~/.tmux.conf` | `shell/.tmux.conf` |
| `~/.config/starship.toml` | `config/starship.toml` |
| `$ZSH_CUSTOM/themes/gruvbox.zsh-theme` | `shell/gruvbox.zsh-theme` |
| `~/Library/Application Support/iTerm2/DynamicProfiles/gruvbox.json` | `config/iterm2/DynamicProfiles/gruvbox.json` (macOS only) |
| `~/.config/nvim` | `config/nvim/` |
| `~/.gitconfig` | `config/git/.gitconfig` |
| `~/.gitignore_global` | `config/git/.gitignore_global` |
| VS Code `settings.json` | `config/vscode/settings.json` |
| VS Code `keybindings.json` | `config/vscode/keybindings.json` |

---

## iTerm2 Preferences Sync

`make macos` points iTerm2's *entire* preferences domain (General settings, Key Mappings, etc. — not just the Dynamic Profile) at `config/iterm2/preferences/com.googlecode.iterm2.plist` via:

```
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/config/iterm2/preferences"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 0   # 0 = save on quit
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
```

After that (and a full quit + relaunch of iTerm2 to pick it up), any setting changed in the iTerm2 GUI is auto-exported back to that file on quit — so `git status` in this repo shows what changed, and a new machine gets identical settings for free after `make macos`.

---

## Shell Functions (from `functions.zsh`)

| Function | What it does |
|----------|-------------|
| `mkcd <dir>` | `mkdir` + `cd` in one step |
| `extract <file>` | Universal archive extractor |
| `fcd` | fzf-powered `cd` |
| `fgb` | fzf git branch checkout |
| `fgl` | fzf git log browser |
| `serve [port]` | Quick HTTP server in current directory |
| `killport <port>` | Kill process on a port |
| `envload [file]` | Source a `.env` file into the shell |
| `fo` | fzf file opener → Neovim |
| `fs <query>` | ripgrep + fzf file content search |

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

---

## After a Fresh Install

```bash
# 1. Reload shell
exec zsh

# 2. Install tmux plugins (inside a tmux session)
# Ctrl+a then I

# 3. Install VS Code extensions
bash config/vscode/install-extensions.sh

# 4. Install macOS apps
make brew-bundle

# 5. Apply macOS system defaults
make macos

# 6. Open Neovim (plugins auto-install via lazy.nvim)
nvim
```
