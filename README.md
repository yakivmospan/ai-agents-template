# `.agents/` — the shared pool

Everything in here is tool-agnostic. It is the folder you drag into a new project.

```
.agents/
├── rules/
│   ├── always/      loaded every session, by both tools — manage this folder freely
│   └── on-demand/   loaded when AGENTS.md's load table says to
├── templates/       AGENTS.md and every spec shape; copied from, never edited in place
├── skills/          shared workflow skills, read by both tools
└── scripts/         setup tooling for this folder (currently: linking skills for Claude)
```

Everything a new project needs from this template lives under `.agents/` plus the three
tool-specific folders (`.claude/`, `.codex/`, and generated `AGENTS.md`/`CLAUDE.md`) — nothing
tool-agnostic sits loose at the repo root.

## Rules: `always/` vs `on-demand/`

`.agents/rules/always/` is a plain folder, not a list hardcoded anywhere. AGENTS.md's one
instruction is: *"read every file in `.agents/rules/always/` before doing anything."* Both Claude
and Codex follow that with their normal file-read tool. Add a file, it loads next session. Delete
one, it stops. Nothing else needs editing.

This is deliberately **not** done with Claude's `@` import syntax, even though that exists and
would auto-inject the content without a tool call. `@` imports name one file at a time and are
Claude-only, so using them here would mean every file added to `always/` also needs a matching `@`
line added to AGENTS.md by hand — defeating the point of it being a folder you manage. The plain
read-instruction is one line, works identically for both tools, and stays in sync with the folder
by construction.

`.agents/rules/on-demand/` is the opposite: loaded only when a specific situation applies (writing
tests, touching architecture, committing). AGENTS.md carries an explicit table for these, because
"load this before that kind of task" *is* a piece of information worth writing down, unlike "load
everything in this folder" which the folder itself already says.

Keep files in `always/` especially short — they load on every single turn's context, every session.

## Adding a rule

- **Always-on**: drop a `.md` file in `.agents/rules/always/`. Nothing else to do.
- **On-demand**: drop a `.md` file in `.agents/rules/on-demand/` and add one row to the load table
  near the top of `AGENTS.md` saying when to read it.

## Skills: discovery vs. invocation

Skill descriptions (not the full body) sit in context from the start of every session — that part
is automatic, not something you opt into per skill. What's *not* automatic is loading the full
`SKILL.md` body: that happens only when a skill is actually used, either because you invoke it
by name (`/my-skill` in Claude, `$my-skill` in Codex) or because the tool decides your request
matches a skill's description closely enough to use it on its own. Both tools support that implicit
match; neither guarantees it for every situation, which is why the description has to be specific —
vague descriptions get skipped by the implicit matcher even though they're always technically visible.

## Adding a skill

```bash
mkdir -p .agents/skills/my-skill
$EDITOR .agents/skills/my-skill/SKILL.md   # frontmatter: name, description
```

`/project-init` links `.agents/skills/` into `.claude/skills/` as part of setup, so a fresh project
needs nothing further. Adding a skill to an **already-initialised** project needs one more step —
but not a manual one. Ask (or just let the agent notice and do it on its own — see `project-link-skills`'s
own description) and the `project-link-skills` skill runs the underlying script for you:

```bash
bash .agents/skills/project-link-skills/scripts/link-skills.sh          # what project-link-skills actually runs, for reference
powershell -File .agents/skills/project-link-skills/scripts/link-skills.ps1   # the Windows equivalent
```

Nobody needs to type either of those directly. `project-link-skills` is one of the skills that ships with
this template specifically so that step never requires a terminal.

Write the `description` as *when to use this, and when not to* — front-load the trigger words,
since that's the field both tools match against for implicit invocation, and it's what a shortened
skill list falls back to if you have many skills installed.

Scripts go in `.agents/skills/my-skill/scripts/`. Prefer stdlib — a skill that needs `pip install`
before it runs is a skill that fails on someone else's machine.
