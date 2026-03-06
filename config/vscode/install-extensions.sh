#!/usr/bin/env bash
# =============================================================================
# install-extensions.sh — Install VS Code extensions from a curated list
#
# Usage: bash config/vscode/install-extensions.sh
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

if ! command -v code &>/dev/null; then
  echo "VS Code CLI (code) not found. Make sure VS Code is installed and"
  echo "'code' is in your PATH (Shell Command: Install 'code' command in PATH)"
  exit 1
fi

extensions=(
  # ── Theme & UI ─────────────────────────────────────────────────────────────
  catppuccin.catppuccin-vsc              # Catppuccin Mocha theme
  catppuccin.catppuccin-vsc-icons        # Matching icon theme
  usernamehw.errorlens                   # Inline error highlighting
  oderwat.indent-rainbow                 # Colored indent guides

  # ── Editor Enhancements ────────────────────────────────────────────────────
  vscodevim.vim                          # Vim keybindings
  mhutchie.git-graph                     # Visual git graph
  eamodio.gitlens                        # Git blame + history inline
  streetsidesoftware.code-spell-checker  # Spell checking
  christian-kohler.path-intellisense     # Path autocomplete

  # ── Languages ──────────────────────────────────────────────────────────────
  ms-python.python                       # Python support
  ms-python.black-formatter              # Python formatter
  charliermarsh.ruff                     # Python linter (fast)
  rust-lang.rust-analyzer               # Rust LSP
  golang.go                             # Go support
  ms-vscode.cpptools                    # C/C++
  esbenp.prettier-vscode                # JS/TS/CSS formatter
  dbaeumer.vscode-eslint                # JS/TS linter
  bradlc.vscode-tailwindcss             # Tailwind intellisense

  # ── Web & Markup ───────────────────────────────────────────────────────────
  ritwickdey.liveserver                  # Live server preview
  redhat.vscode-yaml                     # YAML with schema support
  tamasfe.even-better-toml              # TOML support
  yzhang.markdown-all-in-one            # Markdown tooling

  # ── DevOps & Cloud ────────────────────────────────────────────────────────
  ms-vscode-remote.remote-ssh           # SSH remote development
  ms-vscode-remote.remote-wsl           # WSL integration
  ms-azuretools.vscode-docker           # Docker support
  amazonwebservices.aws-toolkit-vscode  # AWS toolkit

  # ── Productivity ──────────────────────────────────────────────────────────
  wakatime.vscode-wakatime              # Coding time tracker
  gruntfuggly.todo-tree                 # TODO/FIXME tree view
)

echo -e "\n${BOLD}Installing ${#extensions[@]} VS Code extensions...${RESET}\n"

for ext in "${extensions[@]}"; do
  # Skip comment lines
  [[ "$ext" == \#* ]] && continue

  if code --list-extensions | grep -qi "^${ext}$"; then
    echo -e "  ${YELLOW}⚠${RESET} Already installed: $ext"
  else
    echo -e "  → Installing: $ext"
    code --install-extension "$ext" --force 2>/dev/null \
      && echo -e "  ${GREEN}✓${RESET} $ext" \
      || echo -e "  ⚠ Failed: $ext (may not exist)"
  fi
done

echo -e "\n${GREEN}${BOLD}Done.${RESET}\n"
