---
name: spec-from-code
description: Bring a spec's content back in line with code that was changed by hand without the spec being updated. Use when explicitly asked to "update the spec", "sync the spec with the code", "the spec is stale, fix it", or when following up on a code-reviewer finding. Code is ground truth, spec changes. Opposite direction from spec-to-code. This is judgment work (reading code, deciding what it now means) — not the structural check spec-sync does.
---

# Spec From Code

Reconciles spec content to match code that changed underneath it. The direction is code → spec:
the code is being treated as ground truth, and the spec's prose is what gets rewritten.

Only run this on direct request, or as the explicit follow-through on a code-reviewer finding the
user has already asked you to act on. Don't rewrite a spec's content on your own initiative just
because you happened to notice a mismatch while doing something else — flag it instead, the same
way `code-reviewer` does, and let the user decide whether now is the time.

## Scope

Figure out what's in scope before touching anything:

- **Named directly** — "update the checkout spec", a specific spec id or file.
- **Named by code path** — "I changed src/checkout/pay.ts, update its spec" — look it up in
  `specs/INDEX.md`.
- **Unscoped** ("the specs are stale") — ask which area, rather than reconciling the whole tree
  at once; a project-wide reconciliation is a much bigger and riskier operation than a targeted one,
  and deserves its own explicit go-ahead.

## What to gather

1. **The spec as it stands** — intent, behaviour rules, acceptance criteria, constraints, public
   surface, `status`.
2. **What actually changed in code** — `git diff` or `git log` against the spec's `owns` glob,
   ideally since the spec's own `updated:` date or since the last commit that touched the spec file
   itself. If git history isn't useful (e.g. squashed, no clean boundary), read the current code
   directly and compare it against what the spec claims.
3. **Existing tests**, if any, under the same glob — they're often the most reliable evidence of
   what the code is actually guaranteed to do, more so than reading implementation details cold.

## What to reconcile, and how to handle each case

- **New public surface not mentioned in the spec** — add it, with acceptance criteria describing
  its success/failure/edge-case behaviour, mirroring the level of detail already in the spec.
- **An acceptance criterion whose behaviour changed** — reword it to match reality. Don't just flip
  its checkbox; verify against code or tests whether it's actually satisfied before touching `[ ]`
  vs `[x]` — a checked box is a claim, not decoration.
- **A constraint the code no longer honours** — this is the highest-stakes case. Don't silently
  loosen the constraint to match the code; that erases a decision someone made on purpose. Flag it
  explicitly and ask whether the constraint was deliberately dropped or the code regressed.
- **An open question the code changes appear to have resolved** — move it into a "Decisions" entry
  with the rationale you can infer, but only if the resolution is genuinely unambiguous from the
  code. If it's a judgment call rather than an obvious resolution, leave the question open and say
  so — don't let an agent quietly settle something a human should decide.
- **Something the spec describes that the code no longer does at all** — don't delete it from the
  spec on your own. It might be an intentionally-deferred requirement (still `draft`), not a dead
  one. Flag it and ask.

## After reconciling

1. Update the spec's `updated:` date. Reconsider `status` — a spec that now accurately describes
   fully-implemented, tested behaviour can move from `draft` to `active`; don't do this
   automatically if there are still open questions or unverified criteria.
2. Run `spec-sync` to refresh `specs/INDEX.md` if this change touched `owns` or moved code.
3. Report concisely: what was updated, what was flagged rather than resolved (constraints, dropped
   requirements, ambiguous resolutions), and why each flagged item wasn't just fixed silently.
