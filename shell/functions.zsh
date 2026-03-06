#!/usr/bin/env zsh
# =============================================================================
# functions.zsh — Useful shell functions
# =============================================================================

# ── Navigation ────────────────────────────────────────────────────────────────

# mkdir + cd in one step
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# cd using fzf fuzzy search
fcd() {
  local dir
  dir="$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza --tree --color=always {} 2>/dev/null || ls {}')" \
    && cd "$dir"
}

# ── Archives ──────────────────────────────────────────────────────────────────

# Universal archive extractor: extract <file>
extract() {
  if [[ ! -f "$1" ]]; then
    echo "extract: '$1' is not a valid file"
    return 1
  fi
  case "$1" in
    *.tar.bz2)  tar xjf "$1"   ;;
    *.tar.gz)   tar xzf "$1"   ;;
    *.tar.xz)   tar xJf "$1"   ;;
    *.tar.zst)  tar --zstd -xf "$1" ;;
    *.tar)      tar xf "$1"    ;;
    *.bz2)      bunzip2 "$1"   ;;
    *.gz)       gunzip "$1"    ;;
    *.zip)      unzip "$1"     ;;
    *.7z)       7z x "$1"      ;;
    *.rar)      unrar x "$1"   ;;
    *.xz)       unxz "$1"      ;;
    *.Z)        uncompress "$1";;
    *) echo "extract: '$1' — unknown archive format"; return 1 ;;
  esac
}

# ── Git ───────────────────────────────────────────────────────────────────────

# Fetch .gitignore templates from gitignore.io
# Usage: gi python,node,macos
gi() {
  curl -sL "https://www.toptal.com/developers/gitignore/api/$*"
}

# fzf-powered git branch checkout
fgb() {
  local branch
  branch=$(git branch --all | grep -v HEAD | fzf --ansi | sed 's/.* //' | sed 's|remotes/origin/||') \
    && git checkout "$branch"
}

# fzf-powered git log browser
fgl() {
  git log --oneline --color=always | \
    fzf --ansi --preview 'git show --color=always {1}' \
        --bind 'enter:execute(git show --color=always {1} | less -R)'
}

# ── Development ───────────────────────────────────────────────────────────────

# Start a quick HTTP server in the current directory
serve() {
  local port="${1:-8080}"
  echo "Serving $(pwd) at http://localhost:$port"
  python3 -m http.server "$port"
}

# Find a port's process
whoisport() {
  lsof -i ":${1}" | grep LISTEN
}

# Kill process on a port
killport() {
  local pid
  pid=$(lsof -ti ":${1}")
  if [[ -n "$pid" ]]; then
    kill -9 "$pid" && echo "Killed process $pid on port $1"
  else
    echo "No process on port $1"
  fi
}

# ── Environment ───────────────────────────────────────────────────────────────

# Print all colors in the terminal
colors() {
  for i in {0..255}; do
    printf "\e[38;5;%dm%3d " "$i" "$i"
    (( (i + 1) % 16 == 0 )) && printf "\e[0m\n"
  done
}

# Source a .env file into the current shell
envload() {
  local file="${1:-.env}"
  if [[ -f "$file" ]]; then
    set -o allexport
    source "$file"
    set +o allexport
    echo "Loaded $file"
  else
    echo "File not found: $file"
  fi
}

# Show top 10 most-used shell commands
topcmds() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
}

# ── Files & Search ────────────────────────────────────────────────────────────

# fzf-powered file opener with preview
fo() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}') \
    && "${EDITOR:-nvim}" "$file"
}

# Search file contents with ripgrep + fzf
fs() {
  local query="${1:-}"
  rg --color=always --line-number --no-heading "$query" \
    | fzf --ansi \
          --delimiter ':' \
          --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    | awk -F: '{print $1 " +" $2}' \
    | xargs -r "${EDITOR:-nvim}"
}
