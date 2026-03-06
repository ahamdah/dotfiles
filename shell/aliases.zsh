#!/usr/bin/env zsh
# =============================================================================
# aliases.zsh — Shell aliases (cross-platform aware)
# =============================================================================

# ── Editor ────────────────────────────────────────────────────────────────────
alias n="nvim"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# ── Navigation ────────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# ── Modern CLI Replacements ───────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -l --icons --group-directories-first --git"
  alias la="eza -la --icons --group-directories-first --git"
  alias lt="eza -T --icons --git-ignore"         # tree view
  alias l="eza -lah --icons --group-directories-first --git"
else
  alias ll="ls -lh"
  alias la="ls -lah"
fi

if command -v bat &>/dev/null; then
  alias cat="bat --style=auto"
  alias less="bat --paging=always"
fi

# ripgrep is invoked as `rg` — no alias needed
# (the old `alias rg="ripgrep"` was wrong; the binary is already called `rg`)

# ── Git ───────────────────────────────────────────────────────────────────────
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph --decorate --all -20"
alias gp="git push"
alias gpu="git push -u origin HEAD"
alias gpl="git pull"
alias gf="git fetch --all --prune"
alias grb="git rebase"
alias gst="git stash"
alias gstp="git stash pop"

# ── Lazygit ───────────────────────────────────────────────────────────────────
command -v lazygit &>/dev/null && alias lg="lazygit"

# ── Docker ────────────────────────────────────────────────────────────────────
alias d="docker"
alias dc="docker compose"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias di="docker images"
alias dex="docker exec -it"

# ── Kubernetes ────────────────────────────────────────────────────────────────
command -v kubectl &>/dev/null && alias k="kubectl"

# ── Network ───────────────────────────────────────────────────────────────────
alias myip="curl -s ifconfig.me && echo"
alias localip="ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print \$1}'"
alias ports="netstat -tulanp 2>/dev/null || netstat -an"

# ── Utilities ─────────────────────────────────────────────────────────────────
alias reload="exec zsh"
alias path='echo "${PATH//:/$'"'"'\n'"'"'}"'   # print PATH one entry per line
alias mkd="mkdir -pv"
alias dud="du -d 1 -h | sort -h"               # disk usage by folder
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"

# ── Tmux ─────────────────────────────────────────────────────────────────────
alias ta="tmux attach -t"
alias tls="tmux list-sessions"
alias tn="tmux new-session -s"
alias tk="tmux kill-session -t"

# ── Platform-specific ────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
  alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES && killall Finder"
  alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO && killall Finder"
  alias brew-cleanup="brew autoremove && brew cleanup --prune=all"
fi

# ── WSL (Windows Subsystem for Linux) ────────────────────────────────────────
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias start="explorer.exe ."
  alias open="explorer.exe"
  alias pbcopy="clip.exe"
  alias pbpaste="powershell.exe -command 'Get-Clipboard'"
fi
