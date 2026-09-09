---
name: project-query-dependencies
description: Use whenever you need to find what calls, imports, inherits from, or otherwise depends on something; trace how one part of the codebase reaches another; or get oriented in an unfamiliar module before changing it. Prefer this over grep or a broad file-reading pass for structural/dependency questions — it resolves real cross-file relationships (calls/imports/inherits, ~40 languages via tree-sitter AST) instead of text matching. Not for full-text search, style questions, or reading a file you already know — use grep/Read directly for those.
---

# Project Query Dependencies

Wraps the `graphify` CLI — a local, AST-based code knowledge graph (tree-sitter, no LLM calls for
code) — to answer dependency and structure questions with one targeted command instead of grepping
or reading through files by hand.

Output lives in `.agents/graphify/` (`graph.json`, `GRAPH_REPORT.md`, `graph.html`) — kept with the
rest of the tool-agnostic pool rather than loose at the repo root.

## Before querying

1. Check `.agents/graphify/graph.json` exists. If not, create the directory and generate it:
   `mkdir -p .agents/graphify && graphify extract . --output .agents/graphify`
2. Check staleness: compare the commit recorded in `graph.json`'s metadata against
   `git rev-parse HEAD`. If they differ, regenerate (same command as above) before querying. Skip
   this check if the graph was already (re)generated earlier in this same session.
3. If `graphify` isn't installed, don't install it silently — that's a new dependency, ask the user
   first. Point them at `uv tool install graphifyy && graphify install` if they want it.

## Answering a question

Pick the narrowest operation that answers it. Never load the whole graph into context.

| Need | Command |
|---|---|
| What depends on / calls / imports X | `graphify query "<question>"` |
| How A reaches B, or the impact of changing one on the other | `graphify path <A> <B>` |
| Orient on one concept/module before touching it | `graphify explain <concept>` |
| Get bearings in an unfamiliar subsystem | read `.agents/graphify/GRAPH_REPORT.md`'s God nodes / Communities sections — already generated, cheap |

Read only the command's own output. Only open `.agents/graphify/graph.json` directly for a query
none of the above cover, and even then pull the specific nodes/edges you need rather than the
whole file.

## When this beats grep / Explore / reading files — and when it doesn't

- Dependency, call-graph, or impact questions ("what calls this", "what breaks if I change X", "how
  does A reach B") → this skill, first. It resolves real relationships, not text matches.
- A free-text search (a string literal, a TODO, an error message) → grep directly; this won't help.
- You already know the exact file to read → just Read it, don't query for it.
- A question about *why* something was built a certain way → `graphify explain <concept>` surfaces
  `# NOTE:`/`# WHY:` comments and ADR/RFC citations as first-class nodes, so check there before
  falling back to the owning spec's Decisions section.

## Scope

Code parsing is local and LLM-free by default — nothing leaves the machine. Only the semantic pass
over docs/PDFs/images/video calls a configured backend, and only if one is set up; don't assume
that's configured in this project unless told so.
