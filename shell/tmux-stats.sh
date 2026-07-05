#!/usr/bin/env bash
# =============================================================================
# tmux-stats.sh — CPU / RAM / disk usage for the tmux status bar
#
# Usage: tmux-stats.sh {cpu|ram|disk}
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
  *)
    echo "usage: tmux-stats.sh {cpu|ram|disk}" >&2
    exit 1
    ;;
esac
