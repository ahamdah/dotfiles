#!/usr/bin/env zsh
# =============================================================================
# .zshrc — Entry point. Sources modular config files.
# =============================================================================

# Guard: only run in interactive shells
[[ -o interactive ]] || return

# ── Source modules ────────────────────────────────────────────────────────────
ZDOTDIR_CUSTOM="${ZDOTDIR_CUSTOM:-$HOME}"

# Resolve the dotfiles directory (follow symlink if needed)
_zshrc_path="${${(%):-%N}:A}"
_zshrc_dir="${_zshrc_path:h}"

_source() {
  local f="$_zshrc_dir/$1"
  if [[ -f "$f" ]]; then
    source "$f"
  else
    echo "[zshrc] Warning: missing $f"
  fi
}

_source exports.zsh     # PATH, env vars, tool exports

# Extra completions (e.g. Homebrew) — must be on FPATH before OMZ runs compinit
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

_source plugins.zsh     # OMZ theme, plugin list, source OMZ (runs compinit)
_source aliases.zsh     # all aliases (OS-aware)
_source keybindings.zsh # bindkey + ZLE widgets
_source functions.zsh   # shell functions (mkcd, extract, serve, etc.)

# ── Smart cd: zoxide ─────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Completions: Oh My Zsh already runs compinit (sourced in plugins.zsh);
# running it again here would double zsh startup cost.

# lg: fuzzy-pick a git repo under the current dir (or $1) and open it in lazygit
unalias lg 2>/dev/null
function lg {
  local root="${1:-$PWD}" repo top list idx=1
  # inside a repo? search its parent so sibling repos show up
  if [[ -z "$1" ]] && top=$(git rev-parse --show-toplevel 2>/dev/null); then
    root="${top:h}"
  fi
  list=$(find "$root" -maxdepth 3 -name .git -type d -prune 2>/dev/null | sed 's|/.git$||' | sort)
  # start with the cursor on the current repo
  [[ -n "$top" ]] && idx=${${(f)list}[(ie)$top]}
  while repo=$(print -r -- "$list" \
      | FZF_DEFAULT_OPTS="--layout=reverse --border=rounded --pointer=▶" \
        fzf --color=16 --prompt="repo> " --bind "start:pos($idx)" \
            --preview 'git -C {} -c color.status=always status -sb; echo; git -C {} log --oneline -5 --color=always'); do
    lazygit -p "$repo"
    # back from lazygit: keep the cursor on the repo we just left
    idx=${${(f)list}[(ie)$repo]}
  done
}
