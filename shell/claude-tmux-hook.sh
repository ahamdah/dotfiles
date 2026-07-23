#!/usr/bin/env bash
# =============================================================================
# claude-tmux-hook.sh — record Claude Code's busy/free state per tmux pane
#
# Wired into Claude Code lifecycle hooks (see ~/.claude/settings.json):
#   UserPromptSubmit → busy     (Claude started working)
#   Stop             → free      (Claude finished — waiting for you)
#   Notification     → waiting   (needs a permission / answer)
#   SessionEnd       → clear      (Claude exited — drop the marker)
#
# State is written to one file per tmux pane; tmux-stats.sh reads them back
# and paints a per-window dot in the status bar. Outside tmux this is a no-op.
#
# Usage: claude-tmux-hook.sh {busy|free|waiting|clear}
# =============================================================================
set -euo pipefail

state="${1:-}"

# Not inside tmux? Nothing to show — exit quietly so the hook never errors.
[[ -n "${TMUX_PANE:-}" ]] || exit 0

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-tmux"
mkdir -p "$STATE_DIR"

# Pane id looks like "%90"; use it verbatim as the filename.
file="$STATE_DIR/$TMUX_PANE"

case "$state" in
  busy|free|waiting) printf '%s' "$state" > "$file" ;;
  clear)             rm -f "$file" ;;
  *) echo "usage: claude-tmux-hook.sh {busy|free|waiting|clear}" >&2; exit 1 ;;
esac

# Repaint the status bar now instead of waiting for the next refresh tick.
tmux refresh-client -S 2>/dev/null || true
