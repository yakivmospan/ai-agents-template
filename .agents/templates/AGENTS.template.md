# {{PROJECT_NAME}}

{{ONE_LINE_DESCRIPTION}}

Specs hold intent. Code holds behaviour. When they disagree, stop and reconcile.

## Always-on rules

Before doing anything else this session, read every file in `.agents/rules/always/`. It currently
holds `core.md` and `specs.md`, but the folder is the source of truth, not this list — if it has
been edited since you last read it, read whatever is actually there.

This is a plain read-with-your-file-tool instruction, deliberately, so it works identically for
Claude and Codex and so adding or removing a file in `.agents/rules/always/` changes what loads
without anyone having to edit this file to match.

## Load on demand

| Before you… | Read |
|---|---|
| edit any file listed in the spec index | its owning spec (look it up, see below) |
| write or change production code | `.agents/rules/on-demand/code-style.md` |
| write or change tests | `.agents/rules/on-demand/testing.md` |
| add a module, move a boundary, choose between designs | `.agents/rules/on-demand/architecture.md` |

Add a file to `.agents/rules/on-demand/` and a row here when a new condition needs its own rules.

## Finding the spec for a file

`specs/INDEX.md` is the routing table: code-path glob → owning spec. Read it once per session.
Before editing a file, match its path against that table (most specific glob wins) and read the
spec it points to. Walk `parent` upward if you need the wider context.

Entry points:
- `specs/00-brief.md` — what this project is and is not
- `specs/01-architecture.md` — components and boundaries
- `specs/INDEX.md` — everything else, routed by code path

## Stack

{{STACK_SUMMARY}}

## Commands

| | |
|---|---|
| Build | `{{BUILD_COMMAND}}` |
| Test | `{{TEST_COMMAND}}` |
| Lint | `{{LINT_COMMAND}}` |
| Format | `{{FORMATTER_COMMAND}}` |

## Structure

{{STRUCTURE_BLOCK}}

## Working style

- Before any multi-file refactor, new module, or design/API-shape decision, delegate to the
  `architect` agent (Claude: fires automatically on description match; Codex: spawn it yourself,
  e.g. "have architect propose two approaches before you touch anything").
- After any non-trivial edit, before reporting work as done, delegate to `code-reviewer` /
  `code_reviewer`. Same caveat — on Codex this needs an explicit ask, it never fires itself.
- When new public surface (function, class, endpoint, screen) is added, delegate to
  `test-writer` / `test_writer`, and point it at the owning spec's acceptance criteria.
- After any structural change to `specs/`, run the `spec-sync` skill to rebuild `specs/INDEX.md`.

## Shared skills

`.agents/skills/` is read natively by Codex and symlinked into `.claude/skills/` for Claude.
Both tools see the same files. Available: `project-init`, `spec-new`, `spec-sync`.
Claude invokes them as `/name`; Codex as `$name` or implicitly by description.
