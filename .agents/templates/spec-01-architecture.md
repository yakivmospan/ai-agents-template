---
id: architecture
title: Architecture
parent: brief
status: active
owns:
  - "{{TOP_LEVEL_SOURCE_GLOB — e.g. src/**}}"
related: [tech]
updated: {{DATE}}
---

# Architecture

> This spec owns the source tree broadly. Feature specs under `specs/features/` own narrower
> globs and take precedence — most specific match wins.

## Shape
{{ARCHITECTURE_SUMMARY — one paragraph: layered? modular monolith? event-driven?}}

## Components
| Component | Responsibility | Code | Spec |
|---|---|---|---|
| {{name}} | {{one line}} | `{{glob}}` | {{spec id, if it has its own}} |

## Boundaries
{{RULES — what may depend on what. State the direction of every allowed dependency.}}

## Cross-cutting concerns
{{logging, auth, error handling, config — where each lives and who owns it}}

## Decisions
Cross-cutting decisions — ones that don't belong to a single feature — live here, in the same
shape as any other spec's Decisions section: what was decided, why, and what was rejected.
- **{{decision}}** — {{why}}. Rejected: {{alternative}}, because {{reason}}.
