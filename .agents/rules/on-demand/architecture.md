# Architecture rules

Read `.specs/01-architecture.md`, `.specs/02-tech.md`, and every affected spec before proposing
anything below.

| Rule | Detail |
|---|---|
| SOLID | Each module has one reason to change; extend via new code, not edits to an existing contract; a substitute implementation must not break callers; keep interfaces small and specific; depend on abstractions, not concrete types. |
| Read first | `.specs/01-architecture.md`, `.specs/02-tech.md` (its Technical constraints and Development approach often bound the option space), and every spec whose `owns` glob overlaps the blast radius, plus the actual code — existing patterns outrank general best practice. |
| A proposal needs | At least two approaches with concrete tradeoffs (migration cost, testability, blast radius), and which specs would change, by id. |
| Boundary or build changes → stop | Flag explicitly, need human sign-off. |
| Record cross-cutting decisions | In `.specs/01-architecture.md`'s Decisions section. |
| Record feature-scoped decisions | In that feature's own spec, under Decisions. |
| Revising a decision | Update the entry in place, note what changed and why — not left to be found only in git history. |
| Boundaries | {{MODULE_BOUNDARY_RULES — e.g. "feature modules may depend on :core, never on each other", "no framework types above the domain layer"}} |
