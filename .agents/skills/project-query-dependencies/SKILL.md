---
name: project-query-dependencies
description: Use whenever you need to find what calls, imports, inherits from, or otherwise depends on something; trace how one part of the codebase reaches another; or get oriented in an unfamiliar module before changing it. Prefer this over grep or a broad file-reading pass for structural/dependency questions — it resolves real cross-file relationships (calls/imports/inherits, ~40 languages via tree-sitter AST) instead of text matching. Not for full-text search, style questions, or reading a file you already know — use grep/Read directly for those.
---

# Project Query Dependencies

Routes dependency, call-graph, and structural questions to the already-installed `graphify` CLI
instead of grepping or reading files by hand, always scoped to code only via its documented
`--code-only` flag. Beyond that flag and the `query`/`path`/`explain` commands below — all
stable, public surface — avoid repeating `graphify`'s other commands or output layout here; those
are internal or version-specific and `graphify`'s to track, not this skill's.

## What to do

1. Confirm the `graphify` command is on PATH. If it's missing, ask the user before installing it
   yourself.
2. Build or refresh the graph: `graphify extract . --code-only`. This needs no API key and makes
   no LLM call — it's pure local AST parsing, so there's no interactive skill/subagent dispatch to
   go through for this. Run it every time this skill's trigger fires; never skip it to save cost,
   since there's no cost to save.
3. Answer with the narrowest command that fits — a plain-language question
   (`graphify query "<question>"`), the path between two named things (`graphify path "<A>" "<B>"`),
   or an explanation of one concept (`graphify explain "<concept>"`). Use only what it returns.
   Don't read `graphify-out/graph.json` directly unless none of the three commands cover the need.

**Never hesitate to (re)build.** This skill exists purely for code dependency questions — calls,
imports, and inheritance all live in code, so docs/papers/images add nothing here and only exist to
trigger real token cost (LLM-based semantic extraction) — `--code-only` skips that path entirely,
so extraction stays free regardless of corpus size or how narrow the question is. A single-symbol
"who depends on X" question is exactly the case this exists for, not a reason to fall back to grep.
There's also nothing to schedule separately: `graphify extract` caches per-file results internally,
so re-running it each time this skill fires only re-parses what actually changed. A docs+code
cross-reference graph ("which code implements this spec section") is a different use of `graphify`
entirely, outside what this skill does.

## When not to use this

- A free-text search (a string literal, a TODO, an error message) → grep instead, this won't help.
- You already know the exact file to read → just Read it, don't query for it.
- A question about *why* something was built a certain way → `graphify explain` first; `# NOTE:`/
  `# WHY:` comments in code are captured even under `--code-only` (they're part of the source file,
  not the docs/semantic pass) and may already answer it. Fall back to the owning spec's Decisions
  section only if that comes up empty.

## Scope

This skill always runs with `--code-only`, so it never makes an LLM call and nothing leaves the
machine — regardless of what backends `graphify` supports elsewhere, this skill's own path never
touches them.
