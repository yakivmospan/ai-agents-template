---
name: spec-sync
description: Rebuild specs/INDEX.md from spec frontmatter and report drift. Use after creating, moving, renaming, or deleting any spec, after moving or deleting code that a spec's `owns` glob points at, and whenever INDEX.md looks stale or a file's owning spec cannot be found.
---

# Spec Sync

`specs/INDEX.md` is generated. Never hand-edit it — regenerate it.

## Run

```bash
python3 .agents/skills/spec-sync/scripts/build_index.py
```

Stdlib only, no install step. Add `--check` to exit non-zero instead of writing (for CI or a
pre-commit hook). Add `--repo-root <path>` if you are not at the repository root.

## Then read the results

The script writes two sections into `specs/INDEX.md` and prints the same to stdout/stderr:

**Drift** — real problems, need a human-meaningful fix, not a suppression:

| Drift | What it usually means | Fix |
|---|---|---|
| `owns '<glob>' matches nothing` | code was moved or deleted, spec was not updated | update `owns`, or set `status: superseded` if the feature is gone |
| `parent '<id>' is not a known spec id` | parent renamed or deleted | repoint `parent`, or reparent to `architecture` |
| `duplicate id` | copy-paste from a template without editing `id` | rename one; ids must be unique |
| `ambiguous ownership` | two globs of equal specificity claim the same files | narrow one of them; a file must have exactly one owner |
| `parent chain forms a cycle` | two specs point at each other | break the cycle at whichever is conceptually the child |

**Not yet specced** — informational, not drift. An area with no owning spec is the expected state
on a large or partially-adopted codebase; `--check` never fails on this. Create a spec with
`spec-new` when a task actually touches that area, not proactively because it showed up here.

## Reporting

After running, tell the user what changed in the routing table. List Drift items with a proposed
fix each — do not fix them silently, since a deleted `owns` glob may mean a deleted feature, which
is a decision the human should make. Mention "Not yet specced" counts only as information, not as
something requiring action; don't phrase an unspecced area as a problem to resolve.
