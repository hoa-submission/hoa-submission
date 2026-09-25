# Humanize plan: solve the clean lean-eval workspace

## Goal Description

Starting only from this official vanilla `lean-eval` workspace, replace the participant-owned proof holes with a complete proof accepted by the benchmark using Lean 4.32.2 and Humanize RLCR.

## Acceptance Criteria

- AC-1: `Submission.lean` and `Submission/` contain no `sorry`, `admit`, or new `axiom`.
- AC-2: `lake build Submission Solution` succeeds without warnings under Lean 4.32.2.
- AC-3: `lake test` succeeds, including comparator and independent-kernel replay.
- AC-4: `Challenge.lean`, `Solution.lean`, `config.json`, `holes.json`, and theorem interfaces remain unchanged; theorem weakening, unsafe axioms, and copied accepted proofs are rejected.

## Path Boundaries

Edit only `Submission.lean` and Lean helpers under `Submission/`. The worker and reviewer have internet access and should use it for Mathlib documentation, source/API lookup, and mathematical research when useful. Do not seek, inspect, or copy an accepted proof for this target or an earlier local solution.

## Dependencies and Sequence

1. Confirm the exact Lean 4.32.2 toolchain and fetch pinned dependencies.
2. Research the mathematics and relevant Mathlib APIs, then implement the proof.
3. Run placeholder checks, `lake build Submission Solution`, and `lake test`.
4. Commit each round, write the requested summary, and address every review finding until Humanize finalizes.
