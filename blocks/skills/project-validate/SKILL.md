---
name: project-validate
description: Use only when asked to "validate the setup", "review the setup", "review our spec setup", "audit the agent setup", "check the setup against the constitution", "score the setup", "find contradictions or leftovers in the setup", or "how many words or tokens does the setup load" — reads the rules, skills, templates, agents, spec process and builder, tests them against the constitution, measures their load, and reports a score, findings and small drafted proposals, changing nothing. Not for writing or reviewing one skill (project-skill), a spec's prose (spec-review), or the spec tree's structure (spec-sync).
---

# Project Validate

A read-only review of the whole setup against its constitution: what breaks it, what contradicts, what
costs too many words, what could go, and what's left over. One report; the user decides what changes.

## Non-negotiables

- **Only on direct request, and read only.** Edit nothing — not even an obvious typo; it goes in the
  report.
- **The constitution is the measure, never the subject.** Never question a principle, and never
  propose anything stricter than it allows. A rule asking for more than it allows is reported as a
  proposal to bring that rule in line.
- **A red flag is the constitution contradicting itself or its source, `.agents/builder/CONSTITUTION.md`, when present, or wording that reads
  against its own intent** — reported on its own with the exact wording to change, never a principle to
  weaken or tighten. Applying one follows the constitution's own rule: show it, ask, and ask once more.
- **Every finding cites `file:line` and quotes the words.** Open the file; when unsure it's a problem,
  it goes under *Questions*.
- **Every proposal needs a reason and a small draft** — a principle it serves, a contradiction or
  leftover it removes, or words it saves. "Cleaner" alone isn't a reason.
- **Deliberate repetition isn't a finding:** a skill's non-negotiables restate rules on purpose.

## 1. Read

1. `.agents/rules/always-on/setup-constitution-rules.md` first — the constitution agents here follow,
   and the measure for everything below.
2. **The setup:** `AGENTS.md`, `CLAUDE.md`, `.agents/rules/` with both loaders, every shared
   `.agents/skills/*/SKILL.md` with its `reference.md` and scripts, `.agents/.templates/`,
   `.claude/agents/`, `.codex/agents/`, `.claude/settings.json`, `.codex/config.toml` and `.agents/README.md`. Personal files
   under `.agents/.local/` are out of scope unless the user asks; `skill_stats.py` labels each skill
   shared or local.
3. **The spec process:** `.specs/README.md`, the root specs (`.specs/0*.md`), and one open change if
   there is one.
4. **The builder**, when `.agents/builder/` is there: `CONSTITUTION.md`, `BUILDER-DESIGN.md`,
   `CHANGELOG.md`, `README.md` and `blocks/`. Its README's tree maps each block to where it's installed:
   a block without a marker should match its installed file; a `.seed.` block is a form the project
   answered, so it differs by design; a `.builder.` block is never installed; a profile skill is
   installed only where it was chosen.

Rules and skills define the process; `.specs/README.md` and `.agents/README.md` describe it and follow
them. With subagents, give each check below to its own reader, briefed with the non-negotiables, and
merge what they find; without, work through the checks in order.

## 2. Checks

### Constitution
Walk each scenario, and say whether the setup honours every principle — naming the file and line that
breaks one:
- A person confirms a criterion by hand, with no test: is it complete, with nothing warning, failing
  or pushing for a test?
- An agent with none of this setup opens `.specs/README.md`: can it find, read, change, plan, build and
  fold in a spec?
- A spec written from existing code: does it take the shortest path to `merged`?
- Someone changes their mind mid-build: does the flow absorb it without ceremony?
- Anywhere: a warning that something won't work without stricter checks, or proposed enforcement?

### Contradictions
Two files disagreeing — rule and rule, rule and skill, skill and template, a README and what it follows;
one term with two meanings, such as `updated:`, `approved`, done or checked. When the builder is there,
also: its `CONSTITUTION.md` against the installed constitution, and each unmarked block against its
installed file. Quote both sides.

### Load
Measure, never estimate:

```bash
python3 .agents/skills/project-skill/scripts/skill_stats.py
python3 .agents/.scripts/build_setup_map.py --check
wc -w AGENTS.md CLAUDE.md .agents/rules/LOADER.md .agents/rules/always-on/*.md .specs/INDEX.md
```

Report three numbers, each with what you added up:
- **Every session:** `AGENTS.md`, `CLAUDE.md`, the loader, the always-on rules, and every shared skill's
  description.
- **A typical task:** every session, plus `.specs/README.md` up to *Change what a spec guarantees*,
  `INDEX.md`, the largest feature spec standing in for the owning one, and the `DECISIONS.md` sections
  core-rules' *Every task* names.
- **One spec change end to end:** a typical task, plus the on-demand rules `LOADER.md` names for a
  change and the bodies of the spec skills core-rules' *Every task* sends it through.

Flag a shared skill over `project-skill`'s budget, a rule restated outside non-negotiables, always-on
content only some tasks need, and a generated file read every session that could be read on demand.

### Simplification
Steps, fields, statuses, warnings or files nobody would miss; two skills or rules doing one job;
instructions an agent would follow the same way without them. For each, say what breaks if it goes —
if nothing does, it's a proposal.

### Leftovers
- A skill, rule, template, script, field or path named in prose that doesn't exist.
- A retired name still used as current: a name the builder's CHANGELOG or decisions record as replaced. History — a CHANGELOG entry, an *Instead of*
  or *Replaced* line — is fine.
- A skill with no link in `.claude/skills/`, or a link for something gone; whatever
  `build_setup_map.py --check` reports about the map — never read the map's HTML for this.
- Script warnings or code paths for removed concepts.
- An unmarked block with no installed file, or the reverse.

## Report

Plain words, in this order. Keep it to what matters: group small leftovers into one finding.

1. **Score** — a table with a whole-number score out of 10 and a one-line reason for each area:
   Follows the constitution, Consistency, Load, Simplicity, Cleanliness. 10 is nothing to fix, 7 small
   fixes, 4 a problem ordinary work will hit, 1 broken. **Overall** = (3 × constitution + the other
   four) ÷ 7, to one decimal.
2. **Red flags** — the constitution contradicting itself or its source, `.agents/builder/CONSTITUTION.md`, when present, or reading against its
   own intent, with the exact wording to change — or "none".
3. **Findings**, by priority, Critical first — a table: #, priority, area, `file:line`, what's wrong
   (quoted), impact on real work. Priority:
   - **Critical** — loses data, fakes a pass or a confirmation, or breaks a principle on ordinary work;
   - **High** — a contradiction or gap ordinary work will hit;
   - **Medium** — a gap an agent can work around, or load or ceremony nobody needs;
   - **Low** — wording, a leftover, a small repeat.
4. **Proposals**, in the priority of what they fix, only for findings worth fixing:

   ```markdown
   #### P1: {title}
   - **Fixes:** #{n} ({priority})
   - **Why it's needed:** {the principle, contradiction, leftover or cost it removes, and what goes wrong without it}
   - **Saves:** {words per session or per change, or "clarity only"}
   - **Risk:** {what could get worse}
   - **Draft:** {the smallest before and after}
   ```
5. **Considered and left alone** — what looked wrong but is deliberate, one line each.
6. **Questions** — what needs the user.

End by asking which proposals to apply, and stop. Applying them later is a change to the setup:
`setup-rules.md` first.
