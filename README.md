# Builder

The template the agent setup is installed from: rules, skills, spec scaffolding and the setup map, as
blocks an agent installs into a project once. Nothing under `blocks/` is specific to one project.

## Setup

Put this folder at `.agents/builder/` in the project — dropped in, or unpacked from the builder's zip —
and ask the agent:

> Set up the agent setup here — follow `.agents/builder/SETUP.md`.

`SETUP.md` surveys the code, asks what it can't find out, and lets you choose optional skills — for
everyone or only for you. It installs the blocks by the tree below, answers every form from the
codebase, writes the root specs and one change per feature for your approval, writes `.agents/SETUP-VERSION`, reports what is still unanswered, and deletes
`.agents/builder/`.

To develop the builder on a real project, use `SETUP-DEV.md` instead — *Develop the builder*.

## Usage

### Where every block lands

`SETUP.md` reads this tree to install, so keep it true when `blocks/` changes. How a block installs is
its filename marker, in *Change the builder*.

```
builder/
├── VERSION  CHANGELOG.md  README.md  BUILDER-DESIGN.md  CONSTITUTION.md  not installed
├── SETUP.md                                                   not installed — the setup prompt
├── SETUP-DEV.md                                               not installed — the developer's setup prompt
└── blocks/
    ├── README.md                            → .agents/README.md
    ├── CLAUDE.md                            → CLAUDE.md
    ├── specs/README.md                      → .specs/README.md
    ├── specs/.gitignore                     → .specs/.gitignore
    ├── rules/always-on/                     → .agents/rules/always-on/
    ├── rules/on-demand/                     → .agents/rules/on-demand/
    ├── rules/builder-dev-rules.builder.md   → .agents/.local/rules/always-on/builder-dev-rules.md
    │                                          (linked by SETUP-DEV.md only)
    ├── rule-templates/
    │   ├── AGENTS.seed.md                   → AGENTS.md
    │   ├── LOADER.seed.md                   → .agents/rules/LOADER.md
    │   ├── LOADER-local.seed.md             → .agents/.local/rules/LOADER.md
    │   ├── setup-constitution-rules.seed.md → .agents/rules/always-on/setup-constitution-rules.md
    │   │                                      (filled with a copy of CONSTITUTION.md)
    │   ├── sensitive-paths-rules.seed.md    → .agents/rules/always-on/sensitive-paths-rules.md
    │   └── workflow-rules.seed.md           → .agents/rules/on-demand/workflow-rules.md
    ├── skills/                              → .agents/skills/        mandatory, always installed
    ├── profiles/
    │   ├── general/
    │   │   └── skills/                      → .agents/skills/        optional, any stack
    │   └── <stack>/
    │       ├── PROFILE.builder.md           detection, tool commands, code-style topics
    │       ├── rules/code-style-rules.seed.md → .agents/rules/on-demand/code-style-rules.md
    │       └── skills/                      → .agents/skills/        optional, this stack
    ├── agents/claude/                       → .claude/agents/
    ├── agents/codex/                        → .codex/agents/
    ├── scripts/                             → .agents/.scripts/
    ├── spec-templates/                      → .agents/.templates/     spec-feature, spec-contract, implementation-plan
    │                                          (spec-0*.builder.md: root specs, read by SETUP.md only)
    ├── settings/
    │   ├── claude-settings.seed.json        → .claude/settings.json
    │   ├── codex-config.toml                → .codex/config.toml
    │   ├── agents.gitignore                 → .agents/.gitignore
    │   └── claude.gitignore                 → .claude/.gitignore
    └── map/SETUP-MAP.seed.html              → .agents/SETUP-MAP.html
```

An optional skill chosen only for the user goes to `.agents/.local/skills/` instead of
`.agents/skills/`.

### Update a project

This version has no update step. To take a newer builder, compare its `blocks/` with the project's
installed files by hand, or ask an AI to: `.agents/SETUP-VERSION` says which version the project came
from, and `CHANGELOG.md` what changed since.

### Develop the builder

A project has the user setup — the setup alone — or the developer setup, with `.agents/builder/` and
the developer rule beside it. Switching is by hand; syncing under the developer setup isn't:

- **Switch to the developer setup** — put the builder at `.agents/builder/` and follow `SETUP-DEV.md`. On a
  project already set up, it compares the two once and asks which way each difference goes, then
  links the developer rule.
- **Develop** — every change to the setup is made in `blocks/` too as you work, with the tree, the
  design and the changelog kept current. Nothing to run or resolve.
- **Switch back** — copy the builder out, then follow `SETUP-DEV.md` and ask to switch back to the
  user setup: it removes the developer rule and deletes `.agents/builder/`.

### Change the builder

Edit `blocks/`, or develop in a project with the developer setup, where changes reach `blocks/` as
they're made. Add a line to `CHANGELOG.md` saying why, and bump `VERSION` for a release.

How a block installs is in its filename. The marker is dropped at install, so `AGENTS.seed.md` lands
as `AGENTS.md`:

| Marker | Kind | Install |
|---|---|---|
| *(none)* | copied | byte for byte; an existing different file is left and reported, never overwritten |
| `.seed.` | a form | only if missing, then the project's; its `{{…}}` are questions an agent answers by reading the codebase, never guesses |
| `.builder.` | stays in the builder | never installed — read by a setup prompt; the developer rule is linked locally by `SETUP-DEV.md` |

- **Move a block** — drag it and fix the tree above. A skill's folder decides who gets it:
  `blocks/skills/` always, `profiles/` when chosen.
- **Add an optional skill** — no copied file may name it. Give it a row in the
  map, and a `rule-templates/LOADER.seed.md` row, as a question the install answers, only if it must run
  in a given situation.
- **Add a stack** — `blocks/profiles/<name>/` with a `PROFILE.builder.md` in `kotlin-android`'s shape,
  `rules/code-style-rules.seed.md`, and `skills/`, which may stay empty. A profile holds what is true
  of a stack, not of a project: the topics a project's code style must answer, not the answers, and
  skills about the stack's tools that work in a repository with none of this setup. The test for a
  sentence: would the next project on this stack want it unchanged?
- **Change the constitution** — a red flag: only on the user's request, confirmed twice. Edit
  `CONSTITUTION.md` only: it is the one source. Its seed holds nothing but the instruction to copy it, and
  setup copies it into the always-on `setup-constitution-rules.md` that agents in a project read.
- **Change the map** — its word counts, totals and file counts are `build_setup_map.py`'s, rewritten
  in place. Its figures and captions are written by hand, and `build_setup_map.py --check` reports a
  rule or skill that has no row yet.

### Change stack

One stack per project, so changing it means starting over, by hand, from the repository root:

```bash
# first copy .agents/rules/, .claude/settings.json and .agents/SETUP-MAP.html somewhere —
# your answers are in them; carry them back by hand after SETUP.md
rm -rf .agents/{rules,skills,.templates,.scripts} .agents/SETUP-VERSION
rm -rf .claude/{agents,skills} .claude/settings.json .codex/agents CLAUDE.md .agents/SETUP-MAP.html
# keep: .specs/, .agents/.local/
```

Then put the builder back at `.agents/builder/` and run `SETUP.md` with the new stack.
`.specs/02-tech.md` still describes the old stack afterwards — describe it again with `spec-create`.

### Test the builder

Set up a scratch copy of a project with `SETUP.md` and read its report: every block where the tree
says, every `{{` left listed, and `.agents/builder/` gone. Then put the builder back, change one
installed rule and follow `SETUP-DEV.md`: it lists only that file and moves it the way you choose. In
the next session, change a rule and check its block changed with it.

## Troubleshooting

- **`SETUP.md` stops straight away** — `.agents/SETUP-VERSION` exists, so the project is already set
  up. Updating is by hand: *Update a project*.
- **`SETUP.md` reports a file it didn't install** — an existing file differed from its block, and
  install never overwrites. Compare the two by hand, or ask an AI to.
- **A change made while developing isn't in the builder** — the developer rule wasn't loaded: it's
  missing from `.agents/.local/rules/always-on/`, or the session started before it was linked.
  Start a new session; if the link is missing, follow `SETUP-DEV.md` again.

## See also

- `CONSTITUTION.md` — the constitution every project gets; everything else here yields to it
- `BUILDER-DESIGN.md` — why the builder works the way it does, and what has to hold before release
- `CHANGELOG.md` — what each version changes, and why
