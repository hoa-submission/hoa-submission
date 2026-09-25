# Humanize plan: solve the clean lean-eval workspace

## Goal Description

Starting only from this official vanilla `lean-eval` workspace, replace the
participant-owned proof holes with a complete proof accepted by the benchmark.
Use Lean 4.32.2 and the Humanize RLCR implementation/review loop.

## Acceptance Criteria

- AC-1: Participant-owned Lean files contain no `sorry`, `admit`, or new `axiom`.
  - Positive test: `rg -n '\b(sorry|admit|axiom)\b' Submission.lean Submission` returns no matches.
  - Negative test: any remaining proof placeholder blocks completion.
- AC-2: The proof elaborates warning-free with the pinned Lean toolchain.
  - Positive test: `lake build Submission Solution` succeeds under Lean 4.32.2.
  - Negative test: any elaboration error or warning blocks completion.
- AC-3: The official comparator accepts the solution.
  - Positive test: `lake test` succeeds, including independent-kernel replay.
  - Negative test: comparator failure blocks completion.
- AC-4: Trusted benchmark files and theorem interfaces remain unchanged.
  - Positive test: `Challenge.lean`, `Solution.lean`, `config.json`, and `holes.json` match the vanilla commit.
  - Negative test: theorem weakening, trusted-file edits, unsafe axioms, or copied accepted proofs are rejected.

## Path Boundaries

Edit only `Submission.lean` and Lean helpers under `Submission/`. Internet use is
allowed for Mathlib documentation, source/API lookup, and mathematical research;
the worker and reviewer should browse when it improves correctness. Do not seek,
inspect, or copy an accepted proof for this target or an earlier local solution.

## Dependencies and Sequence

1. Confirm `lean-toolchain` is exactly `leanprover/lean4:v4.32.2`.
2. Fetch the pinned dependencies and Mathlib cache if needed.
3. Research the statement and relevant Mathlib APIs, then implement the proof.
4. Run the elaboration and comparator tests above.
5. Commit each completed round and write the Humanize-requested summary.
6. Address every independent review finding until Humanize finalizes the loop.
