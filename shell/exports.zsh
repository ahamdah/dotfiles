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
# .zshenv already sets the base PATH (user dirs + Homebrew via brew shellenv).
# Don't prepend system dirs here — that would shadow Homebrew binaries.
# typeset -U dedupes PATH while keeping the first (highest-priority) entries.
# -g is required: this file is sourced from inside the _source() function in
# .zshrc, and plain `typeset -U path` there creates a function-local shadow of
# path/PATH that reverts (to nothing) the moment _source() returns — wiping
# out /usr/bin, /bin, etc. for the rest of exports.zsh (breaking `tr`, `mv`,
# and anything else run later in this file, e.g. nvm.sh) even though PATH
# looks fine again once .zshrc finishes.
typeset -gU path
# GOBIN holds binaries from `go install` (defaults to $(go env GOPATH)/bin).
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
path=("$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin" "$GOBIN" $path)
export PATH

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# ── nvm (Node Version Manager) ────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ── .NET ──────────────────────────────────────────────────────────────────────
# Pin `dotnet` to the .NET 8 LTS SDK. dotnet@8 is keg-only — dotnet@9 owns the
# linked `dotnet` in $HOMEBREW_PREFIX/bin — so its bin dir must come first in
# PATH to win. DOTNET_ROOT points things that don't go through PATH (IDEs,
# apphosts, MSBuild-spawned processes) at the same install. To move to another
# version, `brew install dotnet@N` and change the two paths below.
if [[ -d "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/dotnet@8" ]]; then
  export DOTNET_ROOT="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/dotnet@8/libexec"
  export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/dotnet@8/bin:$PATH"
fi
# Binaries from `dotnet tool install --global`
[[ -d "$HOME/.dotnet/tools" ]] && export PATH="$HOME/.dotnet/tools:$PATH"

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

# ── VS Code ───────────────────────────────────────────────────────────────────
# Use the CLI shipped inside the app bundle instead of VS Code's own
# "Install 'code' command in PATH" helper. That helper writes a root-owned
# symlink into /usr/local/bin pointing at wherever the app happened to be —
# which, for a quarantined app, is a throwaway /AppTranslocation/... mount that
# disappears on reboot, leaving a dangling `code` that fails as "command not
# found". Prepended so it wins over any such stale symlink still in
# /usr/local/bin. `code-insiders` users: add the Insiders bundle the same way.
[[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] && \
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# ── Antigravity ───────────────────────────────────────────────────────────────
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && \
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
