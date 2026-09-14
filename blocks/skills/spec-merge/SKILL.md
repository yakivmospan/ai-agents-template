---
name: spec-merge
description: Use when asked to "merge the spec", "fold it in", "close/finish PROJ-1234", "I think it's done", or when the user approves a new spec written from existing code — folds a finished change under .specs/changes/ into .specs/: confirms its criteria, marks each spec file merged and copies it over its place, carries over what the spec gained since it was copied, keeps what the plan decided, adds Change history, syncs, then deletes the folder. Not for building a change (spec-implementation-plan); abandoning a change is deleting its folder on the user's yes.
---

# Spec Merge

A change folds in when the user says it's done — or, for a spec written from code that already exists,
when they approve the reading. Until then, `.specs/` still describes the code as it was before the change.

## Non-negotiables

- **Only when the user says the change is done, or approves a spec written from code.** Unticked
  tasks are listed, never a reason to ask again.
- **Every criterion is confirmed before it folds in.** List the unchecked ones — for a contract criterion, with the feature criteria a yes also confirms — and ask once, each its own
  answer: confirmed by the user, as `Source: Manual`; dropped — into an Open question when it's still
  wanted; or the change stays open. For a
  spec written from code, that answer comes with the approval.
- **Nothing the spec in `.specs/` gained since it was copied is lost** — carry it into the copy first.
- **Show what the plan leaves behind before writing any of it**, so the user sees what is dropped.
- **Ask before deleting the change folder — approving a new spec written from code is that yes.** Where
  `.specs/` isn't committed, nothing brings it back. A change nested in it is never deleted with it.

## 1. Before folding in

1. Read, if not already read this session, `.agents/rules/on-demand/spec-change-rules.md`, `spec-format-rules.md` and
   `spec-style-rules.md`.
2. List any unticked tasks. Ask the one question about unchecked criteria, unless the approval already
   answered it; stop there if the user keeps the change open.
3. For each copy of an existing spec, compare it with the spec in `.specs/`. Every difference should be
   this change's own; one that isn't — a section, a criterion or a decision the spec gained after the
   copy was made — goes into the copy. When it's unclear which side a difference came from, show it
   and ask.

## 2. Copy the spec files over

- **Each `specs.<path>.md`** replaces `.specs/<path>`, or creates it — `specs.feature.logger.md` lands
  at `.specs/feature/logger.md`. Delete template comments and every heading left empty.
- **Everything else** — status, `updated:`, the Change section, confirmed and dropped criteria, contract
  criteria and a removal: per spec-change-rules' *Folding in*.

## 3. What the plan leaves behind

Follow spec-change-rules' *Folding in*, and show it as a list before writing any of it: each `Not` line
that becomes a Decision, each flow that goes into the contract spec, each invariant for a module's
`ARCHITECTURE.md`, and what is dropped.

## 4. Finish

- For a change made ahead of code, offer `spec-review --fix` on the specs it touched; run it only on a
  yes.
- Report what folded in, which criteria were confirmed or dropped, which tasks were left, what the plan
  left behind and what was dropped. Then delete the change folder — only its own files while a change is nested in it, and a parent folder left empty — on the user's yes, or on the
  approval of a new spec written from code. Whether or not the folder goes, run `spec-sync` and report its drift and warnings.
