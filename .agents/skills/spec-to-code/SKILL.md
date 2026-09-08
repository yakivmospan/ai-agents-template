---
name: spec-to-code
description: Bring code in line with a spec that was changed by hand — a new or reworded acceptance criterion, a revised constraint. Use when explicitly asked to "implement this spec", "the spec changed, update the code", "make the code match the spec", or similar. Spec is ground truth, code changes. Opposite direction from spec-from-code — don't use this one when the code is right and the spec is what's stale.
---

# Spec To Code

Implements whatever a spec currently requires that the code doesn't yet satisfy. The spec is
ground truth here — if the code disagrees with it, the code is what's wrong.

Only run this on direct request. Implementing code is a much bigger action than reconciling a
spec's text, and should never happen because an agent noticed a gap on its own.

## Scope

- **Named directly** — "implement the checkout spec's retry criterion."
- **Named by spec id** — look up its `owns` glob in `specs/INDEX.md` to find the code.
- **The whole spec** — every currently-unchecked acceptance criterion under it.

If the request is ambiguous about how much to implement, ask rather than guessing scope — building
more than was asked is not a safe default here, since it can touch code the user didn't intend to
change yet.

## Before writing code

1. Read the spec in full: intent, behaviour rules, every acceptance criterion (checked and
   unchecked), constraints, and public surface. The unchecked criteria are the actual task list.
2. Read `.agents/rules/on-demand/code-style.md` and the current code under the spec's `owns` glob —
   match existing patterns, don't introduce a new style for just this change.
3. If satisfying a criterion requires a real design decision (more than one reasonable approach,
   meaningful tradeoffs, or touches a module boundary), delegate to the `architect` agent first
   rather than picking an approach unilaterally — this mirrors AGENTS.md's own Working style rule,
   it isn't a special case invented for this skill.
4. If the spec has open questions that block a specific criterion, don't resolve them yourself by
   picking an interpretation. Implement what isn't blocked, and report the rest as blocked on that
   open question — same principle as `spec-from-code`: an agent doesn't get to silently settle a
   question a human left open on purpose.

## Implementing

- Work criterion by criterion where practical — it keeps the diff reviewable and makes "is this
  criterion actually done" a concrete, checkable question rather than a vague judgment call later.
- After any non-trivial change, delegate to `code-reviewer` before considering it done — again, this
  is just AGENTS.md's existing Working style rule, not a new one.
- When the change adds public surface, delegate to `test-writer`, pointing it at the specific
  acceptance criteria it should turn into tests.

## After implementing

1. Check off each acceptance criterion that is now genuinely satisfied — verified by the tests
   `test-writer` produced or by your own inspection, not checked speculatively because the code
   "should" work.
2. Update the spec's `updated:` date. If every criterion is now checked and reviewed, consider
   whether `status` should move from `draft` to `active` — but leave it as-is if anything remains
   unverified or open.
3. Run `spec-sync` to refresh `specs/INDEX.md` if this change touched `owns` or moved code.
4. Report what was implemented, what got checked off, and anything left blocked on an open question
   or a design decision still pending human sign-off.
