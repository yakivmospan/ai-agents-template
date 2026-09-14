# Project Skill — examples

Bad and good versions of the parts a skill most often gets wrong. The rules are in `SKILL.md`.

## Description

Bad — no triggers, no boundary:
> Helps with specs and keeping documentation in good shape.

Good:
> Use when asked to "review this spec" or "check the spec for style issues" — reviews specs against
> spec-style-rules.md: duplication, implementation leaking into a guarantee, a Decision with nothing
> rejected. Not for writing or changing requirements (spec-create).

## Stop

Bad — the agent has to invent the behaviour:
> If the change isn't ready, handle it appropriately.

Good:
> the spec file isn't `status: approved` — stop, and say which approval is missing. Never approve on the user's
> behalf.

## Non-negotiable

Bad — needs a citation to mean anything:
> Follow spec-style-rules' *Guarantee, not implementation*.

Good:
> **Criteria state guarantees, not implementation** — no tunables, internal class names or call
> sites; name a symbol only when it is the public surface the criterion is about.

## Restated rule

Bad — a copy that drifts from its source:
> Commit subjects are `PROJ-<n>: <Sentence case summary>`, with `PROJ-0:` for build fixes, and…

Good:
> Commit per `workflow-rules.md`.
