# AGENTS.md — Dotfiles Development Environment

This repository manages personal development environment configuration across **macOS**, **Ubuntu/Linux**, and **WSL2**.

## Repository Structure

```
dotfiles/
├── shell/
│   ├── .zshrc              ← Sources all modules below
│   ├── exports.zsh         ← PATH, env vars, tool exports
│   ├── aliases.zsh         ← Aliases (cross-platform guarded)
│   ├── plugins.zsh         ← OMZ plugin list + theme
│   ├── keybindings.zsh     ← bindkey + ZLE widgets
│   └── .tmux.conf          ← Tmux (Catppuccin theme, TPM)
├── config/
│   ├── starship.toml       ← Starship prompt (Catppuccin)
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore_global
│   ├── vscode/
│   │   ├── settings.json
│   │   └── keybindings.json
│   └── windows-terminal/
│       └── settings.json
├── scripts/
│   ├── setup.sh            ← Full installer (macOS + Linux)
│   └── link.sh             ← Symlinks only
├── Makefile                ← Entry point
├── Dockerfile              ← Ubuntu 22.04 test container
└── README.md
```

## Commands

```bash
make install      # Install tools + link dotfiles
make link         # Create symlinks only
make link-force   # Overwrite existing symlinks
make update       # git pull + re-link
make check        # Validate all shell scripts + JSON
make clean        # Remove all symlinks
```

### Docker test

```bash
docker build -t dotfiles-dev .
docker run --rm dotfiles-dev
```

### Manual validation

```bash
bash -n scripts/setup.sh
bash -n scripts/link.sh
bash -n shell/.zshrc
shellcheck scripts/setup.sh   # if shellcheck installed
```

---

## Code Style

### Shell Scripts

- `set -euo pipefail` at the top of every script
- 2-space indentation
- `snake_case` for variables, `UPPER_CASE` for env vars
- `[[ ]]` not `[ ]` for conditions
- Quote all variable expansions: `"$var"`
- `$(...)` not backticks for substitution

### Zsh Module Order (`.zshrc`)

1. `exports.zsh` — PATH and env vars first
2. `plugins.zsh` — OMZ config + source
3. `aliases.zsh` — depends on tools being in PATH
4. `keybindings.zsh` — ZLE widgets last

### Cross-platform Guards

```zsh
# macOS-only
if [[ "$(uname)" == "Darwin" ]]; then
  ...
fi

# WSL-only
if grep -qi microsoft /proc/version 2>/dev/null; then
  ...
fi
```

---

## Editor Setup

- **Font**: Cascadia Code NF (Nerd Font), 16px, ligatures on
- **Theme**: Catppuccin Mocha
- **Icons**: Catppuccin Mocha icon theme
- **Format on save**: enabled

## Key Tool Notes

| Tool | Note |
|------|------|
| `starship` | Configured in `config/starship.toml`, Catppuccin palette |
| `zoxide` | Replaces `cd` — init'd with `--cmd cd` in `.zshrc` |
| `eza` | Replaces `ls` — only aliased if binary exists (safe) |
| `bat` | Replaces `cat` — only aliased if binary exists |
| `delta` | Git pager — configured in `config/git/.gitconfig` |
| `nvm` | Sourced in `exports.zsh`, not `.zshrc` directly |
| `tmux` | Prefix is `Ctrl+a`; plugins auto-restore sessions |
