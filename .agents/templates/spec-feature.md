---
id: feature.{{SLUG}}
title: {{FEATURE_NAME}}
parent: architecture
status: draft
owns:
  - "{{CODE_GLOB}}"
jira: {{JIRA_KEY — e.g. TZG-1234, or omit the field entirely if there isn't one yet}}
related: []
updated: {{DATE}}
---

# {{FEATURE_NAME}}

<!--
  If this feature is one piece of a larger multi-module contract, delete this comment and fill in
  "Implements" below. If it's standalone, delete the whole "Implements" section instead — don't
  leave it as a placeholder nobody filled in.
-->

## Implements
Part of `contract.{{PARENT_CONTRACT_SLUG}}` — satisfies AC-{{N}}, AC-{{M}} from that contract.
See that spec for the full product-level Given/When/Then; this section only needs to say *which*
of those this module is responsible for, not repeat them.

## Intent
{{One paragraph: what this feature guarantees to the rest of the system. Not how.}}

## Acceptance criteria

Each criterion is Given/When/Then, not a one-line summary. A bare "- [ ] retry on network
failure" tells nobody — not a future agent, not future you — what "retry" actually means: how
many attempts, what backoff, what the caller observes while it's happening. Write the criterion
so someone with zero context could implement or verify it from this text alone.

- [ ] **AC-1: {{descriptive name}}**
  Given {{precondition — the state the system/user is in before the trigger}}
  When {{trigger — a single, specific action}}
  Then {{observable outcome — status code, return value, visible state change}}
  And {{additional outcome, if there is one}}

- [ ] **AC-2: {{the failure/negative path — don't only spec the happy path}}**
  Given {{precondition}}
  When {{trigger}}
  Then {{what observably happens instead — an error shape, a rejected state, nothing changing}}

<!-- Add more as needed. Number sequentially. A criterion that can't be written as Given/When/Then
     usually means the requirement itself is still vague — that's worth noticing, not papering
     over with vaguer prose. -->

## Constraints
{{Performance budgets, ordering guarantees, idempotency, concurrency assumptions.}}

## Public surface
{{The entry points other code is allowed to use. Everything else is internal.}}

## Solution
<!--
  Left empty at spec-creation time on purpose — this is written AFTER implementation and review,
  once you actually know what was built and why, not guessed at up front. Don't fill this in with
  a plan; fill it in with what happened. If the plan and what happened match exactly, say that
  briefly; if they diverged, that divergence is the actually useful part to record.
-->
{{Key modules/approach actually used, and why — enough for a future agent to orient without
  re-reading the whole diff.}}

## References
{{Pointers to documentation that already lives elsewhere — a module's own README, a design doc, a
  Confluence page — so it isn't duplicated here. e.g. "`modules/{{name}}/README.md` — API surface
  reference."}}

## Change history
<!-- Optional — add this section the first time a change happens after the spec is first written.
     Don't ship it as an empty stub on a brand-new spec. -->
Every change to this spec's behavior after it was first written — ticket-driven or not. `jira:`
above is only the origin ticket, if there was one. Add a row, never overwrite one.

| Ticket | Change | Date |
|---|---|---|
| {{ticket key, or "No ticket" if there wasn't one}} | {{what changed}} | {{DATE}} |

## Decisions
- **{{decision}}** — {{why}}. Rejected: {{alternative}}, because {{reason}}.

## Open questions
- [ ] {{unresolved — do not let an agent silently resolve these}}
