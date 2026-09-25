#!/usr/bin/env bash
set -Eeuo pipefail

RUN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$RUN_ROOT/workspaces"
RUN_CODEX_DIR="${RUN_CODEX_DIR:-$RUN_ROOT/.runtime/codex-home}"
HUMANIZE_ROOT="${HUMANIZE_ROOT:-$RUN_ROOT/humanize}"
MODEL="${MODEL:-gpt-5.6-sol}"
EFFORT="${EFFORT:-max}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-21600}"

[[ -x "$HUMANIZE_ROOT/scripts/setup-rlcr-loop.sh" ]] || {
  printf 'missing Humanize setup script under %s\n' "$HUMANIZE_ROOT" >&2
  exit 1
}
[[ -x "$HUMANIZE_ROOT/hooks/loop-codex-stop-hook.sh" ]] || {
  printf 'missing Humanize Stop hook under %s\n' "$HUMANIZE_ROOT" >&2
  exit 1
}
command -v codex >/dev/null || { printf 'missing command: codex\n' >&2; exit 1; }
command -v tmux >/dev/null || { printf 'missing command: tmux\n' >&2; exit 1; }

mkdir -p "$RUN_CODEX_DIR" "$RUN_ROOT/logs" "$RUN_ROOT/pids"

problems=(
  chudnovsky_formula_for_pi_inv
  furstenberg_measure
  hopf_rinow
  morse_inequality
  rado_riemannSurface
  thue_siegel_roth
  weak_morse_inequality
  wigner_semicircle
)

worker_prompt='Act as the proof implementer for this Humanize RLCR loop. Read the active .humanize/rlcr/*/round-*-prompt.md and HUMANIZE_PLAN.md, then carry the loop through implementation, independent review, fixes, comparator validation, and finalization. Begin from the current clean Submission files. You and the Humanize reviewer have live internet access; use web research for Mathlib documentation, mathematical references, and API verification when useful. Do not inspect or copy accepted target proofs, Seed Prover outputs, or earlier local solutions. Use Lean 4.32.2, edit only participant-owned files, commit each completed round, write every requested Humanize summary, and obey every Stop-hook response until the hook allows completion.'

for problem in "${problems[@]}"; do
  workspace="$WORKSPACE_ROOT/$problem"
  log_file="$RUN_ROOT/logs/$problem.log"
  session_name="seedgap-$problem"

  [[ -d "$workspace" ]] || { printf 'missing workspace: %s\n' "$workspace" >&2; exit 1; }
  [[ "$(tr -d '\r\n' < "$workspace/lean-toolchain")" == "leanprover/lean4:v4.32.2" ]] || {
    printf 'wrong Lean toolchain in %s\n' "$workspace" >&2
    exit 1
  }

  if [[ ! -d "$workspace/.git" ]]; then
    git init -q -b main "$workspace"
    git -C "$workspace" config user.name "Humanize Seed-Gap Worker"
    git -C "$workspace" config user.email "humanize-seed-gap@example.invalid"
    git -C "$workspace" add .
    git -C "$workspace" commit -q -m "chore: clean lean-eval vanilla start"
  fi

  if [[ ! -d "$workspace/.humanize/rlcr" ]]; then
    (
      cd "$workspace"
      CODEX_HOME="$RUN_CODEX_DIR" \
      DEFAULT_CODEX_MODEL="$MODEL" \
      DEFAULT_CODEX_EFFORT="$EFFORT" \
      bash "$HUMANIZE_ROOT/scripts/setup-rlcr-loop.sh" \
        HUMANIZE_PLAN.md \
        --track-plan-file \
        --base-branch main \
        --max 42 \
        --codex-model "$MODEL:$EFFORT" \
        --codex-timeout "$TIMEOUT_SECONDS" \
        --yolo \
        --privacy \
        > .humanize-setup.log 2>&1
    )
  fi

  if tmux has-session -t "$session_name" 2>/dev/null; then
    printf '%s already running in tmux session %s\n' "$problem" "$session_name"
    continue
  fi

  worker_command=(
    env
    "CODEX_HOME=$RUN_CODEX_DIR"
    "HUMANIZE_ROOT=$HUMANIZE_ROOT"
    codex exec
    --cd "$workspace"
    --model "$MODEL"
    --dangerously-bypass-approvals-and-sandbox
    --dangerously-bypass-hook-trust
    --color never
    -c "model_reasoning_effort=\"$EFFORT\""
    -c 'network_access="enabled"'
    -c 'web_search="live"'
    "$worker_prompt"
  )
  printf -v shell_command '%q ' "${worker_command[@]}"
  printf -v quoted_log '%q' "$log_file"
  shell_command+=" >>$quoted_log 2>&1"
  tmux new-session -d -s "$session_name" -c "$workspace" "$shell_command"
  printf '%s\n' "$session_name" > "$RUN_ROOT/pids/$problem.session"
  printf 'launched %s in tmux session %s\n' "$problem" "$session_name"
done
