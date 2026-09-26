# IOI 2026 isolated review-loop worker

Solve the one official task stored in this repository and follow `plan.md`.

- Read and write only inside this repository. Do not inspect parent, sibling,
  cache, archive, or unrelated workspace paths.
- Do not use the network, web search, official/editorial solutions, alternative
  solutions, hidden tests, grading data, or pre-existing submissions.
- Follow the active loop prompt and Stop-hook feedback exactly.
- Never edit harness state files or reviewer result files manually, bypass a
  blocked hook, cancel the loop, or substitute an ad-hoc review.
- Commit every implementation round before writing its required summary.
- Produce the exact solution path required by `plan.md`, a rigorous explanation,
  independent tests, and an executable repository-root `test.sh`.
- Continue until the harness creates `complete-state.md`; passing a local test alone
  is not completion.
