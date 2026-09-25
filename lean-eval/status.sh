#!/usr/bin/env bash
set -Eeuo pipefail

RUN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

printf '%-43s %-10s %-8s %s\n' problem process round state
for workspace in "$RUN_ROOT"/workspaces/*; do
  problem="$(basename "$workspace")"
  session_name="seedgap-$problem"
  process_state=stopped
  pid=-
  if tmux has-session -t "$session_name" 2>/dev/null; then
    process_state=running
    pid="$(tmux list-panes -t "$session_name" -F '#{pane_pid}' | head -n 1)"
  fi
  state_file=
  if [[ -d "$workspace/.humanize/rlcr" ]]; then
    state_file="$(find "$workspace/.humanize/rlcr" -mindepth 2 -maxdepth 2 -name state.md -type f | sort | tail -n 1)"
  fi
  round=-
  loop_state=-
  if [[ -n "$state_file" ]]; then
    round="$(awk -F: '/^current_round:/{gsub(/[[:space:]]/, "", $2); print $2; exit}' "$state_file")"
    loop_state="$(awk -F: '/^status:/{sub(/^[^:]*:[[:space:]]*/, ""); print; exit}' "$state_file")"
  fi
  printf '%-43s %-10s %-8s %s (pid %s)\n' "$problem" "$process_state" "${round:--}" "${loop_state:--}" "$pid"
done
