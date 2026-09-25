We’re the Anonymous team. We’ve now solved 165 problems on Lean-Eval, a public, submission-based leaderboard for formalizing research-level mathematics in Lean.

Its main benchmark currently has 239 problems, plus 8 internal tests that do not count toward the ranking. These are not short tactic exercises. The catalog includes the Green–Tao theorem, Ben Green and Terence Tao’s landmark result that the primes contain arbitrarily long arithmetic progressions, alongside Feit–Thompson, Brouwer fixed point, Abel–Ruffini, Cauchy–Kovalevskaya, and Hopf–Rinow.

Lean-Eval keeps the original statements trusted and overlays only solver-owned proof files onto clean workspaces. A problem counts only if comparator and the independent kernel accept it, giving 165 a shared, machine-checkable meaning.

The core lesson is that flow and agent loops can amplify model capability. Before Humanize starts, we ask a model to turn the mathematical idea into an explicit natural-language proof. The worker then maps that proof to the exact Lean statement, Mathlib APIs, and bridge lemmas.

Humanize and RLCR keep the goal fixed across rounds. One agent implements, an independent reviewer finds gaps, and compiler errors, failed verification, and review feedback become work for the next round. The Stop hook prevents premature completion. The loop does not replace reasoning; it gives the model structure, memory, external feedback, and repeated chances to recover from mistakes.

IMO 2026 showed the same principle at a smaller scale, when GPT-5.6 and Kimi K3 independently reached 6/6 Lean-verified solutions. Lean-Eval extends that evidence to a much broader set of research-level mathematics.

Lean-Eval leaderboard:
https://leanprover.github.io/lean-eval-leaderboard/

Lean-Eval benchmark:
https://github.com/leanprover/lean-eval

Our process:
https://github.com/anonymous/lean-eval-code

IMO 2026:
https://github.com/anonymous/imo2026
