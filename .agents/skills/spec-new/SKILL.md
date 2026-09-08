---
name: spec-new
description: Create a new spec under specs/ with correct frontmatter, parent link, and code ownership glob, then rebuild the index. Use when adding a feature that has no spec, when a piece of work spans multiple modules and needs a story-level contract first, or when a task touches an area of an existing codebase that has no spec yet.
---

# Spec New

## Before writing anything

1. Read `.agents/rules/always/specs.md` if it is not already in context, and `specs/00-brief.md`
   for the project's Non-goals — a new spec that contradicts one of them is a flag to raise with
   the user, not something to write as asked.
2. Read `specs/INDEX.md`. Check the thing you are about to spec does not already have one under a
   different name — extending an existing spec beats adding a near-duplicate.
3. Decide the parent. Default is `architecture` for a standalone feature. A feature that
   is genuinely a sub-part of another feature parents to that feature instead. A feature that is
   one module of a larger multi-module piece of work parents to that work's story spec.
4. If this is one piece of a larger effort spanning multiple modules, check whether a story spec
   already exists for it before creating a feature spec in isolation — see "Stories" below.

## Pick a template

| Situation | Template | Destination |
|---|---|---|
| New feature or module | `.agents/templates/spec-feature.md` | `specs/features/<slug>.md` |
| Work spanning multiple modules, needs a shared contract | `.agents/templates/spec-story.md` | `specs/stories/<slug>.md` |

Copy it, do not write from memory — the frontmatter contract has required keys.

A binding technical decision isn't a separate spec — record it in the Decisions section of
whichever spec it affects (the feature/story it's scoped to, or `01-architecture.md` if it's
cross-cutting). See "Fill it" below.

## Stories

Only reach for `spec-story.md` when work genuinely fans out across multiple modules — most work is
a single feature spec. Story mechanics (`owns: []`, the `Implementation` table, the size-judgment
for whether a task gets its own file) are in the "Stories" row of `.agents/rules/always/specs.md`'s
Writing table — don't re-derive them here.

## Fill it

- `id` — dot-namespaced and unique: `feature.<slug>` or `story.<slug>`.
- `owns` — the glob(s) this spec is the source of truth for. **Verify each glob actually matches
  files on disk before saving.** If the code does not exist yet, use `owns: []` and add the glob in
  the same commit that adds the code. Story specs always keep `owns: []`.
- `jira` — the source ticket key, if one exists. Optional; delete the field entirely rather than
  leaving the placeholder if there isn't one.
- `status` — `draft` until the behaviour it describes is implemented and tested.
- Acceptance criteria — full Given/When/Then per criterion, not a one-line summary. A criterion
  that can't be written this way usually means the requirement itself is still vague — surface
  that rather than writing a vaguer version to paper over it.
- `Implements` (feature specs that are part of a story only) — name which of the parent story's
  AC ids this module satisfies. Don't repeat the story's Given/When/Then here.
- `Solution` and `References` — leave these for after implementation; don't fill them with a plan.
- Decisions — record any choice that constrains future work in the spec's own Decisions section,
  with the rejected alternative and why. A decision that isn't scoped to this spec (it affects
  other features too) belongs in `01-architecture.md`'s Decisions section instead.
- Open questions — leave them open. Do not resolve an unknown by picking something plausible; that
  is exactly the failure mode specs exist to prevent.

## Ask, do not guess

If intent, constraints, or acceptance criteria cannot be derived from code, existing specs, or the
conversation, ask the user. List what you need in one batch rather than one question at a time.

## Finish

Run the `spec-sync` skill. Confirm the new spec appears in both the routing table and the tree, and
that no new drift was introduced.

## On an existing codebase with an unspecced area

This is the normal, expected way most coverage gets built — reactively, when a task actually
touches a part of the codebase that has no spec yet, not as a proactive full-coverage exercise.
Two things are different here from writing a spec for brand-new work:

- **Describe what the code actually does, not what it should ideally do.** Acceptance criteria for
  existing, working behaviour get written and checked off as already-satisfied — you're
  documenting reality, not proposing a plan. Where the existing behaviour is genuinely unclear or
  looks wrong, that's an Open question, not a criterion you invent to sound complete.
- **The `owns` glob doesn't need to cover the whole module right away.** If you're only touching
  one part of a large legacy area, scope the glob to that part now — narrower, real coverage beats
  a wide glob backed by a spec that only actually describes a fraction of what it claims to own.
  Broaden it later, in a future change, when something else in that module actually gets touched.
