# How we created the Lean proofs

This repository is the reproduction source for an experiment in which eight
independent workers formalized difficult `lean-eval` theorems. Each worker
started from an official clean workspace selected on 2026-08-07; no target came
with a prefilled participant proof.

- Benchmark commit: `53348531969dc984e02e3be0379a7282c664abd9`
- Lean toolchain: `leanprover/lean4:v4.32.2`
- Worker model: `gpt-5.6-sol` at `max` effort
- Reviewer model: `gpt-5.6-sol` at `max` effort
- Parallel workers: 8
- Worker network: enabled, with live web search
- Reviewer network: enabled, with live web search
- Humanize maximum iterations: 42 per problem
- Worker/reviewer timeout: 21600 seconds

Humanize and RLCR provided the implementation-and-review loop, but they were
only one part of the proof-development process. The mathematical outline,
translation into the exact Lean statement, Mathlib research, intermediate lemma
design, elaboration fixes, and benchmark validation were all separate and
necessary parts of creating each proof.

## Proof-creation process

### 1. Freeze a clean benchmark target

We reconstructed each workspace from the same pinned `lean-eval` commit and
Lean toolchain. `Challenge.lean`, `Solution.lean`, `config.json`, and
`holes.json` form the trusted benchmark boundary. Only `Submission.lean` and
modules under `Submission/` are participant-owned.

This matters because a proof is not accepted merely because a nearby theorem
compiles: it must prove the original statement without changing the statement,
weakening its assumptions, adding axioms, or modifying the comparator setup.

### 2. Ask a model for a natural-language formalization first

Before writing `HUMANIZE_PLAN.md` or starting Humanize, we asked a model to
formalize the mathematical argument as a natural-language proof. This first
pass turned the theorem description and cited source into an explicit proof
strategy: the main reduction, the intermediate lemmas, and the facts that a
formal proof would need.

Where the source workspace exposes it, the resulting informal strategy is
recorded in that problem's `README.md` as the **Informal solution**. It is
scaffolding rather than trusted evidence: the later Lean development still had
to check whether every step was expressible using the exact definitions in the
challenge and the APIs available in the pinned Mathlib version.

Doing this before Humanize separated two questions that are easy to conflate:

1. Why is the theorem mathematically true?
2. How can that argument be represented with the definitions and lemmas
   available to Lean?

### 3. Translate the paper proof into a Lean route

The worker then read the exact theorem signature and unfolded the challenge's
supporting definitions. It researched the pinned Mathlib source and
documentation, searched for reusable theorems, checked namespaces and typeclass
requirements, and identified where local bridge lemmas would be needed.

This stage often changes the route suggested by the informal proof. A textbook
argument may depend on a theory that Mathlib does not yet expose, while the
formal statement may admit a shorter route through an existing theorem or a
consequence of the definitions. Small scratch examples, `#check` queries, and
incremental builds are used to confirm APIs before committing to a large proof.

### 4. Write an executable proof plan

Only after the natural-language and library-reconnaissance passes did we write
each `HUMANIZE_PLAN.md`. The plan converts the proof task into auditable
acceptance criteria:

- no `sorry`, `admit`, or new `axiom` in participant-owned files;
- warning-free elaboration with Lean 4.32.2;
- successful comparator and independent-kernel replay via `lake test`; and
- no changes to trusted benchmark files or theorem interfaces.

The plan also fixes the edit boundary, allows mathematical and Mathlib research,
and forbids looking up an accepted target proof or copying an earlier local
solution.

### 5. Implement against Lean's feedback

Each worker implemented the proof in `Submission.lean`, moving reusable or
bulky lemmas into `Submission/Helpers.lean` or additional local modules. The
practical loop was:

1. state the next helper lemma;
2. elaborate it with the pinned toolchain;
3. diagnose type, coercion, namespace, simplification, or typeclass failures;
4. revise the formal argument; and
5. rebuild before composing the next layer.

For these targets, this implementation work—not merely invoking an agent
loop—is where the informal mathematics was converted into kernel-checkable Lean
terms.

### 6. Use Humanize RLCR for independent review and correction

Humanize ran the worker and an independent Codex reviewer in an RLCR
(Ralph-Loop with Codex Review) cycle. At the end of a round, the worker committed
its changes and wrote a structured summary. The reviewer checked the work
against the immutable goal and acceptance criteria. Review findings were fed
back into the next implementation round until the proof and its surrounding
code passed review.

The tracked `.codex/hooks.json` registers Humanize's native `Stop` hook. When a
worker attempts to finish, the hook can reject the stop and require another
round. After implementation review completes, Humanize also runs a code-review
phase to catch correctness, maintainability, or scope problems that ordinary
elaboration may not reveal.

### 7. Validate the result at the benchmark boundary

A result is complete only after all of the following agree:

```bash
# Run inside one workspaces/<problem>/ directory.
lake build Submission Solution
lake test
```

We also check participant-owned files for proof placeholders and verify that the
trusted benchmark files are unchanged. `lake build` establishes that the code
elaborates with the pinned environment; `lake test` invokes the official
comparator and independent-kernel replay. Passing a worker's local check alone
is not sufficient.

## What this repository contains

The repository contains the reproducible *starting point* for that process:

- eight clean benchmark workspaces and their original proof holes;
- the model-assisted informal solution sketches in the workspace READMEs;
- the Humanize plans and acceptance criteria;
- the pinned Humanize runtime and Stop-hook configuration; and
- scripts for launching and monitoring the eight independent runs.

It intentionally excludes concrete run output: completed or partial proofs,
Humanize RLCR state, Codex state, dependency/build caches, generated Lake
manifests, logs, PIDs, and tmux session data. In other words, this is a
reproduction source repository, not an archive of accepted proof terms or model
transcripts.

Run `bash status.sh` to inspect all eight workers.

## Reproduce

Requirements:

- Codex CLI with access to `gpt-5.6-sol`
- `git`, `tmux`, `ripgrep`, and the Lean/Lake prerequisites
- the benchmark comparator available as `COMPARATOR_BIN` or in `PATH` for
  final `lake test` validation

Clone the repository and launch the workers:

```bash
git clone git@github.com:anonymous/lean-eval-code.git
cd lean-eval-code
bash launch.sh
bash status.sh
```

The Humanize v1.16.0 runtime is bundled under `humanize/`.

`MODEL`, `EFFORT`, `TIMEOUT_SECONDS`, and `RUN_CODEX_DIR` may be overridden in
the environment. `HUMANIZE_ROOT` may also point to another Humanize checkout;
by default it resolves to the bundled directory. The defaults reproduce the
original run configuration.

The bundled runtime was exported from
[`anonymous/humanize`](https://github.com/anonymous/humanize) at commit
`0ec921a36b4365df503511c5567bbd3e02db0df5` (Humanize v1.16.0). Its upstream
Git history and caches are not vendored.

The Stop hook uses a 21600-second timeout. `launch.sh` passes the configured
`HUMANIZE_ROOT` into each worker so the hook remains portable.

## Repository scope

Each directory under `workspaces/` is reconstructed from its original baseline
commit, before a worker ran. The source includes benchmark statements, empty
participant submissions, pinned Mathlib revisions, comparator wrappers, and the
Humanize plans needed to reproduce the experiment.
