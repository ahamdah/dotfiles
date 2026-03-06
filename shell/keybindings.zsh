#!/usr/bin/env zsh
# =============================================================================
# keybindings.zsh — Zsh keybindings and ZLE widget customizations
# =============================================================================

# ── Word navigation ──────────────────────────────────────────────────────────
# Ctrl+Backspace → delete word backward
bindkey '^H' backward-kill-word
# Ctrl+Delete → delete word forward
bindkey '^[[3;5~' kill-word

# ── fzf integration ──────────────────────────────────────────────────────────
# Load fzf shell integration (provides Ctrl+T, Ctrl+R, Alt+C)
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# If using Homebrew fzf on macOS
if [[ "$(uname)" == "Darwin" ]] && command -v fzf &>/dev/null; then
  local fzf_zsh="$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh"
  [[ -f "$fzf_zsh" ]] && source "$fzf_zsh"
fi

# ── Shift-selection (text selection with Shift+Arrow keys) ───────────────────
# Ref: https://stackoverflow.com/questions/5407916/zsh-zle-shift-selection

r-delregion() {
  if ((REGION_ACTIVE)); then
    zle kill-region
  else
    local widget_name=$1
    shift
    zle "$widget_name" -- "$@"
  fi
}

r-deselect() {
  ((REGION_ACTIVE = 0))
  local widget_name=$1
  shift
  zle "$widget_name" -- "$@"
}

r-select() {
  ((REGION_ACTIVE)) || zle set-mark-command
  local widget_name=$1
  shift
  zle "$widget_name" -- "$@"
}

# key    kcap    seq          mode       widget
for key kcap seq mode widget in \
  sleft   kLFT   $'\e[1;2D'  select     backward-char \
  sright  kRIT   $'\e[1;2C'  select     forward-char \
  sup     kri    $'\e[1;2A'  select     up-line-or-history \
  sdown   kind   $'\e[1;2B'  select     down-line-or-history \
  send    kEND   $'\E[1;2F'  select     end-of-line \
  send2   x      $'\E[4;2~'  select     end-of-line \
  shome   kHOM   $'\E[1;2H'  select     beginning-of-line \
  shome2  x      $'\E[1;2~'  select     beginning-of-line \
  left    kcub1  $'\EOD'     deselect   backward-char \
  right   kcuf1  $'\EOC'     deselect   forward-char \
  end     kend   $'\EOF'     deselect   end-of-line \
  end2    x      $'\E4~'     deselect   end-of-line \
  home    khome  $'\EOH'     deselect   beginning-of-line \
  home2   x      $'\E1~'     deselect   beginning-of-line \
  csleft  x      $'\E[1;6D'  select     backward-word \
  csright x      $'\E[1;6C'  select     forward-word \
  csend   x      $'\E[1;6F'  select     end-of-line \
  cshome  x      $'\E[1;6H'  select     beginning-of-line \
  cleft   x      $'\E[1;5D'  deselect   backward-word \
  cright  x      $'\E[1;5C'  deselect   forward-word \
  del     kdch1  $'\E[3~'    delregion  delete-char \
  bs      x      $'^?'       delregion  backward-delete-char \
; do
  eval "key-$key() { r-$mode $widget \$@ }"
  zle -N "key-$key"
  bindkey "${terminfo[$kcap]-$seq}" "key-$key"
done
