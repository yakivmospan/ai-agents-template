---
name: project-query-dependencies
description: Answers dependency, call-graph, and structural questions (what calls/imports/inherits from something, how one part of the codebase reaches another) using the `graphify` CLI. ONLY on direct request — the user explicitly asks to use graphify, or explicitly asks for this skill by name. Never proactive, never invoked in place of grep or a broad file-reading pass just because a question happens to be structural in shape.
---

# Project Query Dependencies

**Only run this on direct request.** Do not invoke it, suggest it, or reach for it automatically
just because a question is structural or dependency-shaped — grep and normal file reading are the
default even for those questions. Only the user explicitly asking for this skill, or explicitly
asking to use `graphify`, counts as a request.

Routes dependency, call-graph, and structural questions to the already-installed `graphify` CLI
instead of grepping or reading files by hand, always scoped to code only via its documented
`--code-only` flag. Beyond that flag and the commands named below — stable, public surface — avoid
repeating `graphify`'s other commands or output layout here; those are internal or version-specific
and `graphify`'s to track, not this skill's.

**No LLM billing from `graphify` itself is not the same as "free."** `--code-only` guarantees
`graphify` never makes a model call, but every tool call's output still costs *you* (the calling
agent) context tokens — extraction logs, a wrong command's output, a widened query budget, `--help`
text. Trial-and-error discovery, not the graph build, is where real cost comes from. Pick the right
command on the first try from the table below instead of rediscovering it live.

## What to do

1. Confirm the `graphify` command is on PATH. If it's missing, ask the user before installing it
   yourself.
2. Build or refresh once: `graphify extract . --code-only`. Do this at most once per session unless
   the code has changed since.
3. Pick the narrowest command for the question — don't guess, don't iterate budgets:

   | Need | Command |
         |---|---|
   | What depends on / calls / imports X (reverse lookup) | `graphify affected "<X>"` (add `--relation`/`--depth` as needed) |
   | How A reaches B | `graphify path "<A>" "<B>"` |
   | Explain one concept | `graphify explain "<concept>"` |
   | A broader natural-language question none of the above fits | `graphify query "<question>"` |

   `affected` wasn't in the graphify README this skill was last checked against — verify its exact
   flags with `graphify affected --help` once if unsure, then reuse what you learn for the rest of
   the session instead of re-checking per query.
4. Use only the answer returned. Don't read `graphify-out/graph.json` directly unless none of the
   above cover the need.

## When this beats grep — and when it honestly doesn't

- Multi-hop or transitive questions (depth ≥ 2, or tracing a path across several hops) — grep can't
  do this at all, and walking imports by hand costs more than one `--depth 2` call.
- Distinguishing real structural usage from incidental text matches — inheritance, interface
  implementations, shadowed/overloaded names — where a plain string search over- or under-counts.
- Repeated questions against a graph already built this session (or one the team committed) — the
  build cost is paid once, every question after that is close to free.
- **A single, direct, textually unambiguous symbol (a distinctive class name, plain imports, no
  inheritance to trace) on a graph that doesn't exist yet this session is a real case where grep may
  cost less overall** — measured directly: "what depends on X" cost more with a cold `graphify`
  build plus command discovery than with grep alone, for exactly this shape of question. Don't
  treat "always use this" as true regardless of shape; a simple depth-1 import lookup is grep's
  best case, not graphify's.
- A free-text search (a string literal, a TODO, an error message) → grep instead, this won't help.
- You already know the exact file to read → just Read it, don't query for it.
- A question about *why* something was built a certain way → `graphify explain` first; `# NOTE:`/
  `# WHY:` comments in code are captured even under `--code-only`. Fall back to the owning spec's
  Decisions section only if that comes up empty.

## Scope

This skill always runs with `--code-only`, so it never makes an LLM call and nothing leaves the
machine.
