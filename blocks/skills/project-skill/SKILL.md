---
name: project-skill
description: Use when asked to "write/create/add a skill", "review this skill", "improve/fix/shorten/trim a skill", "why didn't the skill trigger", "the skill loaded on the wrong request", or before changing any SKILL.md under .agents/ — writes, reviews and tests skills so both Claude and Codex load them on the right request and follow them. Not for rules or loaders (setup-rules.md), a skill missing from Claude's list (project-link-skills), reviewing the whole setup (project-validate), READMEs, or code comments.
---

# Project Skill

A skill is read mid-task and skimmed. It works when the right request loads it and every step says
when it's done and when to stop.

## Non-negotiables

- **The description decides whether the skill ever loads.** Trigger phrases first, in the words
  people actually say; then what it does in one clause; then **Not for**, naming what to use instead.
- **What the skill can't run without comes first** — at most six bullets, each understandable without
  following a citation.
- **Every step ends in something checkable, and every stop says what to tell the user.** "Stop and
  say which approval is missing", never "handle it appropriately".
- **Point at a rule by name, never restate it** — the non-negotiables are the one exception.
- **Deterministic work goes in a script**, standard library only.
- **A change leaves a skill better, never worse or stricter than its rule** — a new or changed skill is
  tested (*Testing*) unless the user skips it; a skipped test or a wording edit is reported as not tested.

## The budget

| Part | Target | Limit |
|---|---|---|
| Description | 70–100 words — both tools match on it, and ignore a long tail | 1,024 characters (Claude's) |
| Non-negotiables | 6 bullets, one or two lines each | — |
| Body | ~1,500 words below the frontmatter, examples included | 500 lines (Anthropic's guidance) |

The test for anything in the body is *does every run need it?* If not, it goes to `reference.md` beside
`SKILL.md`, named from the step that needs it — whatever the count. "Shorten" means down to the target
unless the user names one. `scripts/skill_stats.py`, given skill names, counts all of it and flags
what's over.

## Writing a skill

1. **Read** `.agents/rules/on-demand/setup-rules.md`. Then every skill's description, and the bodies of the two or
   three nearest this one:
   ```bash
   python3 .agents/skills/project-skill/scripts/skill_stats.py
   ```
   Two skills matching the same request is a conflict: narrow the description you're writing with a
   **Not for** naming the other. Changing a sibling's needs the user's yes; if the jobs genuinely
   overlap, stop and ask whether to merge them.
2. **Pin the job down.** In one message, with your inference beside each: which requests should load
   it and which near misses shouldn't, in the user's words; what it produces; where it stops; where it
   goes — builder, this project, or only the user (setup-rules' *Where a skill goes*). Skip what the
   request already answers. **Wait for the answers.**
3. **Copy `templates/skill-template.md`** to the skill's folder as `SKILL.md`, and write to the budget.
   `reference.md` has a bad and a good description, stop, non-negotiable and pointer.
4. **Test** (*Testing*), **wire in** (*Wiring*), and **report** its path, each test prompt and what it
   showed, and what was wired in.

## Reviewing, shortening or fixing a skill

1. Read the skill and `setup-rules.md`. For each point, note the line and a proposed fix:
   1. **Description** — triggers first; a **Not for** naming alternatives; no overlap with a sibling's.
   2. **Non-negotiables** — present, at most six, each understandable alone.
   3. **Stops** — each says what to tell the user. Flag "as appropriate", "if needed", "handle".
   4. **Restated rules** — a passage copying a rule file becomes a pointer.
   5. **Budget** — over it, or content not every run needs: what moves to `reference.md`.
   6. **Script candidates** — steps that are the same every run.
   7. **Dead references** — every path, skill and rule it names exists. Check, don't assume.
   8. **Both tools** — nothing only one tool runs: a hook, an `@` import, a tool-specific name as the
      only way to do a step.
   9. **Independent, for a profile skill** — nothing relies on `.specs/`, `.agents/` or another skill
      being there; naming one conditionally is fine (setup-rules' *Optional skills stay independent*).
   10. **True to its rule** — each stop, exception and condition matches the rule it points at, scope
       included: an exception a rule sets for one case stays that narrow, and a stop the rule doesn't
       have is a new gate, not a fix. Open the rule and compare the words.
   11. **Agrees with its siblings** — a skill that hands work to or from this one says the same about
       every case they share: who builds, who approves, who folds in.
2. **Asked only to review:** report per skill, most serious first, and stop.
3. **Asked to change it** ("shorten", "fix", "trim"): the request is the go-ahead for findings that
   serve it. Apply those, list the others, then *Testing* and *Wiring*, and report what changed.

## Changing several skills at once

Two or more skills or rules that hand work to each other, changed in one go — not a sibling's **Not
for** line alongside a trigger fix. Each skill can end up better and the flow between them broken. So:

1. **Keep a copy** of every file it may touch, unless git tracks it, and say where.
2. **Baseline:** offer `project-validate` before the edits (it runs only on request); on a yes, keep
   its scores and findings.
3. **Brief each helper by pointer:** the rule's name and the whole bullet or section it sits in,
   heading included — never a paraphrase, which drops the scope. Skills that share a flow (write, build,
   fold in) go to one helper, or are compared after.
4. **Walk each shared flow** across the edited skills and their rules: every branch of an exception the
   pass touched, and the ordinary cases — a spec written from code, a change of mind mid-build, "it's
   done" with a task left. Two files saying different things is fixed before anything is reported.
5. **Compare**, when the baseline ran: rerun `project-validate` the same way. A new High or Critical
   finding, or a new finding in a file the pass edited, is fixed before "done". Scores move a point
   between runs, so a lower score alone means rerunning that area once. Report before and after; restore
   from the copy only on the user's yes.

## Diagnosing a skill that didn't load

1. Compare the user's exact words with the description: a missing trigger, or a sibling matching them
   better, is the usual cause. Confirm with *Testing*'s trigger half.
2. **Asked only why:** report the cause and the description you'd propose, and stop.
3. **Asked to fix it:** change the description — or, if the skill must run in that situation whatever
   the wording, add a `LOADER.md` row (setup-rules' *Where a rule goes*). Then *Testing* and
   *Wiring*, and report the cause and the fix.

## Testing

A fresh agent that hasn't seen this conversation (a subagent, where the tool has them), with 2–3
realistic prompts: at least one that should load the skill, one near miss that shouldn't.

- **Trigger:** give it every skill's description (`scripts/skill_stats.py`) and a prompt; ask which it
  would load. A wrong pick is a description to fix.
- **Follow:** give it `SKILL.md` and a prompt; ask for its steps, its stops, and what it had to
  invent. Each is a body to fix.
- **Regression**, for a changed skill: keep its old text before editing — a copy, unless git tracks
  it — and run a prompt the old text already handled on both. The new does at least as well, and never
  stops or asks where the old didn't, unless its rule changed.

Fix and rerun, three rounds at most; then report the prompt still failing and what the agent did.
With no fresh agent, do it yourself and say it wasn't independent.

## Wiring

- Run `project-link-skills`.
- The READMEs and `LOADER.md`, per setup-rules' *Keep the README true*, *Keep the specs README true* and
  *Where a rule goes*.
- **A skill that comes from a builder block**, a profile skill included, **where the project keeps
  `.agents/builder/`:** the same change in its block under `.agents/builder/blocks/` — even when it
  was installed only for the user — and a map row if it's shared.
- **Installed only for the user** (in `.agents/.local/skills/`, even behind a link in
  `.agents/skills/`): its loader row goes in `.agents/.local/rules/LOADER.md`. A skill the user wrote
  only for themselves has no block unless they ask to share it.
