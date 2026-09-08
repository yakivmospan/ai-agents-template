---
id: story.{{SLUG}}
title: {{STORY_NAME}}
parent: architecture
status: active
owns: []
jira: {{JIRA_STORY_KEY}}
related: []
updated: {{DATE}}
---

# {{STORY_NAME}}

<!--
  Use this template only when one piece of work fans out across multiple modules/features and
  you want the full product-level contract written once, in one place, rather than duplicated
  (or lost) across each module's own spec. If a task is scoped to a single module, it doesn't
  need this tier — just write a normal feature spec (spec-feature.md) directly.

  `owns: []` is deliberate — a story never owns code directly. Every code path is owned by one
  of the feature specs underneath it (see the Implementation table below). If you find yourself
  wanting to add a glob here, that's a sign the work should probably just be a feature spec
  instead of a story.
-->

## Source
{{Where this originated — e.g. "Full requirements in Jira ([TZG-XXXX](url))." This spec is the
  AI-facing contract derived from it, not a replacement for it — keep it in sync by hand when the
  ticket changes materially. If there's no external ticket, say "Originated here" instead.}}

## Acceptance criteria

The full product-level contract, Given/When/Then, lives here and only here — feature specs
underneath reference these by ID (AC-1, AC-2, ...) rather than repeating them. This is the one
section that should read the same whether the reader is an AI, a new team member, or you in six
months.

- [ ] **AC-1: {{descriptive name}}**
  Given {{precondition}}
  When {{trigger}}
  Then {{observable outcome}}
  And {{additional outcome}}

- [ ] **AC-2: {{next scenario — happy path, failure path, and edge cases each get their own}}**
  Given {{precondition}}
  When {{trigger}}
  Then {{observable outcome}}

<!-- Add as many as the story actually has. Don't compress multiple scenarios into one AC to
     make the list shorter — that's exactly the compression that makes an AC unimplementable. -->

## Implementation

The traceability matrix. This is what answers "which module handles AC-6" without re-deriving it
by reading every feature spec underneath.

| Task spec | Module | Satisfies |
|---|---|---|
| `feature.{{slug}}` | new: `{{path}}` | AC-1, AC-2 |
| `feature.{{slug}}` | existing: `{{path}}` | AC-3, AC-4 |

Not every piece of work under a story needs its own row here in the form of a separate spec file.
When a task is small enough, fold it straight into the feature spec it belongs to instead —
add it as another acceptance criterion there, with a one-line note on which ticket it came from,
rather than creating a whole new file for it. Give it its own child spec (`parent:` pointing at
this story, or at the feature spec it's really part of) only once it's substantial enough to
warrant being found on its own — its own module, its own meaningfully separate set of criteria,
or its own review cycle. There's no fixed threshold for this; it's a size judgment made at
architecting time, not a rule this template enforces.

## Decisions
Choices made while architecting this story that constrain how the modules underneath implement
it — which modules exist at all, how they divide responsibility, shared contracts between them.
A decision scoped to just one module's internals belongs in that module's own feature spec instead.
- **{{decision}}** — {{why}}. Rejected: {{alternative}}, because {{reason}}.

## Open questions
- [ ] {{anything not yet resolved at the story level — module-specific unknowns belong in that
  module's own feature spec instead}}
