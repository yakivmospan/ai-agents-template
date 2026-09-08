# Core rules

Always-on. Read before any task.

## Ground rules

| Rule | Detail |
|---|---|
| KISS, always | Code, specs, docs, explanations. Simplest thing that satisfies the actual requirement — no speculative flexibility, no premature abstraction, no restating the obvious. |
| Specs vs. code conflict | Stop and say so before writing anything. Do not silently pick a side. |
| No invented facts | If a convention, command, or requirement isn't written down or visible in the code, ask — don't fill the gap with ecosystem defaults. |
| Scope | One feature or module per change. Touching a second one needs a stated reason first. |
| Sensitive paths | Ask before touching: {{SENSITIVE_PATHS — e.g. build.gradle.kts, .github/workflows/, migrations/, infra/}} |
| Unsure | Say "I don't know" and name the missing input. A wrong confident answer costs more than a question. |

## Every task

| Step | Action |
|---|---|
| 1 | Read `specs/INDEX.md` if not already read this session. |
| 2 | For each file you'll edit, check the index for an owning spec and read it if found. No match is normal on a partially-specced codebase, not a blocker. |
| 3 | Do the work — the spec if there is one, the code itself if not. |
| 4 | Spec's intent changed → update it in the same change. No spec existed and the task is substantial enough to be worth finding later → consider adding one. A one-line fix doesn't need one. |
