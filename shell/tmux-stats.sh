#!/usr/bin/env bash
# =============================================================================
# tmux-stats.sh — CPU / RAM / disk / Claude state for the tmux status bar
#
# Usage: tmux-stats.sh {cpu|ram|disk|claude <window_id>}
# =============================================================================
set -euo pipefail

case "${1:-}" in
  cpu)
    if [[ "$(uname)" == "Darwin" ]]; then
      # `-n 0` skips the process list so the sample returns immediately.
      top -l 1 -n 0 | awk '/CPU usage/ {gsub("%","",$7); printf "%.0f%%", 100-$7}'
    else
      # Field position of "id" (idle) varies by locale/top version, so scan for it.
      top -bn1 | awk -F'[, ]+' '/Cpu\(s\)/ {for (i=1;i<=NF;i++) if ($i=="id") printf "%.0f%%", 100-$(i-1)}'
    fi
    ;;
  ram)
    if [[ "$(uname)" == "Darwin" ]]; then
      vm_stat | awk '
        /^Pages free/                      {gsub("[.]","",$NF); free=$NF}
        /^Pages active/                    {gsub("[.]","",$NF); active=$NF}
        /^Pages inactive/                  {gsub("[.]","",$NF); inactive=$NF}
        /^Pages speculative/               {gsub("[.]","",$NF); spec=$NF}
        /^Pages wired down/                {gsub("[.]","",$NF); wired=$NF}
        /^Pages occupied by compressor/    {gsub("[.]","",$NF); compressed=$NF}
        END {
          total = free + active + inactive + spec + wired + compressed
          used  = active + wired + compressed
          if (total > 0) printf "%.0f%%", used / total * 100
        }'
    else
      free | awk '/^Mem:/ {printf "%.0f%%", $3/$2*100}'
    fi
    ;;
  disk)
    df -h / | awk 'NR==2 {print $5}'
    ;;
  claude)
    # Print a colored dot for the state of any Claude Code session running in
    # window $2. State files are written per-pane by claude-tmux-hook.sh; here
    # we map each one back to its *current* window (live, so it follows panes
    # that get moved) and reduce to the single most actionable state.
    #
    # Precedence (most actionable first): waiting > free > busy. "waiting" and
    # "free" both mean "it wants you"; "busy" means leave it be.
    target="${2:-}"
    [[ -n "$target" ]] || exit 0

    STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-tmux"
    [[ -d "$STATE_DIR" ]] || exit 0

    # Newline-separated pane-id lists. Kept as plain strings (not associative
    # arrays) so this runs on macOS's stock bash 3.2 too.
    live_panes="$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null || true)"
    target_panes="$(tmux list-panes -t "$target" -F '#{pane_id}' 2>/dev/null || true)"

    best=""   # "" < busy < free < waiting
    rank() { case "$1" in waiting) echo 3 ;; free) echo 2 ;; busy) echo 1 ;; *) echo 0 ;; esac; }

    for f in "$STATE_DIR"/%*; do
      [[ -e "$f" ]] || continue
      pane="$(basename "$f")"
      if ! grep -qxF "$pane" <<< "$live_panes"; then
        rm -f "$f"          # pane is gone — self-heal the stale marker
        continue
      fi
      grep -qxF "$pane" <<< "$target_panes" || continue
      st="$(cat "$f" 2>/dev/null)"
      [[ "$(rank "$st")" -gt "$(rank "$best")" ]] && best="$st"
    done

    # Leading space keeps the dot off the window name. The format string's own
    # trailing #[...] block restores fg/bg right after, so we only set fg here.
    case "$best" in
      waiting) printf ' #[fg=#fe8019]⚠' ;;   # orange — needs a decision
      free)    printf ' #[fg=#b8bb26]●' ;;   # green  — done, waiting for you
      busy)    printf ' #[fg=#8ec07c]⟳' ;;   # aqua   — working, leave it be
      *)       : ;;                           # no Claude here — print nothing
    esac
    ;;
  *)
    echo "usage: tmux-stats.sh {cpu|ram|disk|claude <window_id>}" >&2
    exit 1
    ;;
esac
