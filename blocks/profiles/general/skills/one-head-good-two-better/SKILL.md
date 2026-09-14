---
name: one-head-good-two-better
description: Use when the user says "apply", "let's go", "do it", "go ahead" or similar and no plan was agreed earlier in the conversation, or asks for a second opinion on an approach — a second look at the request against the project's rules and a simpler or safer way, then proceed, ask one short question, or stop with a red flag and a draft of the better direction. Not for the go-ahead of a plan just agreed, questions or explanations, or mid-task.
---

# One head good, two better

Before acting on a go-ahead with no agreed plan behind it, take one honest look at what was asked. The
point is catching the few requests that would be built wrong or redone — not reviewing everything.

## Look for

Only these. Anything smaller isn't worth the user's attention.

1. **Breaks the project's own rules** — `AGENTS.md`, `CLAUDE.md`, the rules they load, recorded
   decisions, where the project has them. Name the rule and its file.
2. **Rework ahead** — the request contradicts itself or something agreed earlier in the conversation,
   or leaves open a choice that decides the outcome.
3. **A clearly better way** — much simpler, already in the codebase, or the request treats a symptom.
4. **Hard to undo** — deletes data, touches something shared or outward-facing, a big blast radius
   for a small ask.

Read only what judging needs: the rules already in context, the files the request names. Don't
research.

## Verdict — exactly one

**Go** — nothing above applies. Don't mention the review; do the work.

**Adjust** — the direction is right, and one to three small things would make it better. One short
message, then wait:

> Before I start: {each adjustment, one line}. Go with these, or as you asked?

**Red flag** — a rule is broken, rework is likely, or there's a clearly better way. Stop:

> 🚩 {what's wrong, in one line}
> - {why — with the rule or file it comes from} (at most three)
>
> A small draft of the other way:
> {5–15 lines — a tree, a sketch, a table: enough to see the difference, not a solution}
>
> Build from this draft, or go ahead as asked?

## Keep it cheap

- One verdict per request. Once the user answers, do what they chose — no second review.
- The user overruling a flag is an answer, not a new trigger.
- Unsure between Go and Adjust → Go. Unsure between Adjust and Red flag → Adjust, unless a project
  rule is broken.
- No praise, no restating the request.
