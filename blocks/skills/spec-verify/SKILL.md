---
name: spec-verify
description: Use when asked to "verify the spec", "check the spec against the code", "is this spec still true", "run the spec's tests", or when the user accepts an offer to check a spec .specs/INDEX.md lists as possibly stale — runs the tests its criteria list, reads the owned code for everything tests don't cover, reports what holds and what differs, and records the result for INDEX.md. Runs in the background. Not for rewriting a stale spec (spec-create), reviewing its prose (spec-review) or rebuilding the index (spec-sync).
---

# Spec Verify

A stale spec is one whose owned code changed after its `updated:` date: it may still be true, or not.
This finds out, without stopping the task that needed the spec.

## Non-negotiables

- **Run in the background** — on Codex, only when asked. The task that needed the spec keeps going; report when the check is done.
- **Reading never checks a criterion.**
- **A difference is a spec-vs-code conflict** — unless an open change's copy of the spec already
  describes the code; name that change instead. Otherwise report it and ask which side is right; never
  fix either side on your own.
- **Check criteria and bump `updated:` only when the whole check is clean** — every listed test ran and passed,
  nothing read as *differs* or *can't tell*. Otherwise the spec isn't touched.
- **No test command you can't find in `.specs/02-tech.md`.** When you can't derive one, skip the tests,
  say so, and still read.
- **Record every run** with `scripts/record_check.py`, so `INDEX.md` shows it beside the spec while it's listed as possibly stale.

## 1. Tests

1. Collect every automated `Source:` under the spec's criteria — the test files and their tests.
2. Work out the command from `.specs/02-tech.md`'s Testing section: for a module-scoped command, the
   module each test file sits in.
3. Hand the run to the `runner` subagent. Note per criterion: all its tests passed, some failed (which),
   or not run.

## 2. Reading

For every criterion with no automated source, and for Intent, Constraints and Public surface: read the
code under the spec's `owns` — the `architect` subagent for a wide glob — and mark each:

- **holds** — the code does what it says;
- **differs** — quote what the code does instead, with file and line;
- **can't tell** — say what's missing to decide.

## 3. Finish

1. **Clean** — every listed test ran and passed, nothing differs or can't tell: check each unchecked criterion whose tests all passed,
   and set `updated:` to today.
2. **Not clean** — change nothing in the spec.
3. **Record, either way:**
   ```bash
   python3 .agents/skills/spec-verify/scripts/record_check.py feature.x --passed 47 --failed 1 \
     --differs AC-5 Intent --cant-tell AC-2
   ```
   Then run `spec-sync`, so `INDEX.md` shows the result.

## Report

Clean, in one line: "`feature.x` verified — tests green 47/47, reading holds; 3 criteria checked,
`updated:` bumped." Otherwise that line, then each failing test, difference and can't-tell with its quote, by priority,
Critical first:
- **Critical** — a checked criterion's test fails, or the code breaks a Constraint or its public surface;
- **High** — the code does something other than what a criterion or the Intent says, where a user or caller sees it;
- **Medium** — a difference only the code's own module sees, or a test that didn't run;
- **Low** — can't tell, or a difference in how the spec describes it rather than what it guarantees.

Then one question: for each difference, is the spec right or the code? Code right: `spec-create` corrects
the spec in place; spec right: fix the code. Tests not run: say so, never "tests green".
