# Core rules

Always-on. Read before any task.

## Ground rules

| Rule | Detail |
|---|---|
| KISS, always | Code, specs, docs, explanations. Simplest thing that satisfies the actual requirement — no speculative flexibility, no premature abstraction, no restating the obvious. |
| Specs vs. code conflict | Stop and say so before writing anything. Do not silently pick a side. |
| No invented facts | If a convention, command, or requirement isn't written down or visible in the code, ask — don't fill the gap with ecosystem defaults. |
| Scope | One feature or module per change. Touching a second one needs a stated reason first. Adding anything beyond what was asked, or unsure whether a request fits this project at all: check `.specs/00-brief.md`'s Non-goals first. |
| Sensitive paths | Ask before touching: {{SENSITIVE_PATHS — e.g. build.gradle.kts, .github/workflows/, migrations/, infra/}} |
| Unsure | Say "I don't know" and name the missing input. A wrong confident answer costs more than a question. |

## Every task

This is the one place the delegation flow is written down — nothing else repeats it.

1. Read `.specs/INDEX.md` if not already read this session. For each file you'll edit, check the
   index for an owning spec and read that spec if found. No match is normal on a partially-specced
   codebase, not a blocker.
2. No owning spec, and the task is substantial enough to be worth finding later: run `spec-new`
   before writing code. A one-line fix doesn't need one.
3. Design choice, new module, or a change touching more than one file: delegate to the `architect`
   subagent (`architect` on Claude, `architect` on Codex) and follow its decision rather than
   picking an approach unilaterally. On Codex this needs an explicit ask — it never delegates on
   its own, no matter how the description reads.
4. Implement. Read `.agents/rules/on-demand/code-style.md` first.
5. New or changed public surface: delegate to the `test-writer` / `test_writer` subagent, pointing
   it at the owning spec's acceptance criteria and at `.specs/02-tech.md`'s Testing section for
   which framework and command actually apply.
6. Build, lint, or full test suite to check the result: delegate to the `runner` subagent instead
   of reading raw command output yourself.
7. Spec's intent changed → update it in the same change: check off satisfied criteria, set
   `updated`, run `spec-sync` if `owns` moved. No spec existed and the task turned out substantial
   → consider adding one now.
