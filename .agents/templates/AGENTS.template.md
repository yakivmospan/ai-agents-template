# {{PROJECT_NAME}}

{{ONE_LINE_DESCRIPTION}}

Specs hold intent. Code holds behaviour. When they disagree, stop and reconcile.

## Always-on rules

Before doing anything else this session, read every file in `.agents/rules/always/` — the folder
is the source of truth for what's always-on, not this line. It currently holds `core.md` (ground
rules and the delegation flow) and `specs.md` (how the `.specs/` tree works); read whatever is
actually there if it has changed since you last read it.

This is a plain read-with-your-file-tool instruction, deliberately, so it works identically for
Claude and Codex and so adding or removing a file in `.agents/rules/always/` changes what loads
without anyone having to edit this file to match.

## Load on demand

| Before you… | Read |
|---|---|
| edit any file listed in the spec index | its owning spec — match its path against `.specs/INDEX.md`, most specific glob wins |
| write or change production code | `.agents/rules/on-demand/code-style.md` |
| add a module, move a boundary, choose between designs | `.agents/rules/on-demand/architecture.md` |
| find what calls/imports/depends on something, or trace a path between two parts of the code | run the `project-query-dependencies` skill instead of grepping by hand |

Add a file to `.agents/rules/on-demand/` and a row here when a new condition needs its own rules.

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
