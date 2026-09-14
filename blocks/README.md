# `.agents/` — the agent setup

The rules, skills and templates Claude and Codex follow in this repository — one setup both tools
read, installed from a builder.

## Setup

A setup prompt installed it once, and `SETUP-VERSION` says which builder version it came from. There
is no update step: a newer builder is compared by hand, or by an AI you ask. Outside this folder the
setup is `AGENTS.md`, `CLAUDE.md`, `.claude/` and `.codex/`.

```
.agents/
├── rules/
│   ├── LOADER.md    what loads, and when — AGENTS.md points here
│   ├── always-on/   loaded every session
│   └── on-demand/   loaded when a row in LOADER.md says to
├── skills/          every installed skill
├── .templates/      the spec and change shapes the spec skills copy
├── .scripts/        tooling no skill owns, like the map's generator
├── .local/          yours only, gitignored
├── .cache/          written by scripts on this machine, gitignored
├── builder/         the builder itself — only where its developer set this project up
├── SETUP-VERSION
└── SETUP-MAP.html
```

What you may edit:

- **Your answers** — `AGENTS.md`, `rules/LOADER.md`, `sensitive-paths-rules.md`,
  `code-style-rules.md`, `workflow-rules.md`, `.claude/settings.json` and the map were installed as
  forms and answered from this codebase. They're this project's.
- **`setup-constitution-rules.md`** — a copy of the builder's constitution, changed only as it says.
- **Everything else installed** — the other rules, skills, templates and scripts — came from the
  builder. Edit them as you need; a newer builder is compared by hand.
- **`.local/`** — yours alone. Nothing in it reaches anyone else.

## Usage

### How rules load

`AGENTS.md` points at `rules/LOADER.md`, then `.local/rules/LOADER.md`. Every file in `always-on/`
loads at the start of each session; a file in `on-demand/` loads when its `LOADER.md` row applies.
Where a new rule goes, and how to write one: `rules/on-demand/setup-rules.md`.

### How skills get used

Every skill's description is in context from the start of a session. Its body loads when you invoke
it by name — `/my-skill` in Claude, `$my-skill` in Codex — or when the tool matches your request to
the description, which isn't guaranteed. A skill that must run in a given situation gets a
`LOADER.md` row naming that situation.

### How a change flows

The specs describe themselves in `.specs/README.md`, for any agent. Here, the skills walk a change
through that process:

1. **Describe it** — `spec-create` writes the spec files, each the whole spec as it should read afterwards,
   with `status: draft` and a `## Change` section saying why.
2. **Plan it, when the work needs it** — `spec-implementation-plan` writes `implementation-plan.md` with
   you: the design, then the tasks in order.
3. **Approve it** — you, in chat: each spec file you approve gets `status: approved`, and you're asked whether the rest go too. A spec written from
   code that already exists folds in on that yes, unless the change also holds work still to build.
4. **Build it** — when you ask (asking approves a draft), `spec-implementation-plan` works through the tasks, stops where a task
   needs you to try it, and changes the plan with you when something turns out different.
5. **Fold it in** — `spec-merge` asks once about each unchecked criterion — confirm, drop, or keep the
   change open — marks the spec files `merged`, copies them over their places in `.specs/`, and deletes
   the folder on your yes.

What each file holds, and what changing course mid-way does: `rules/on-demand/spec-change-rules.md`.

### Adding a skill

From the repository root:

```bash
mkdir -p .agents/skills/my-skill
$EDITOR .agents/skills/my-skill/SKILL.md   # frontmatter: name, description
bash .agents/skills/project-link-skills/scripts/link-skills.sh    # powershell -File …/link-skills.ps1 on Windows
python3 .agents/.scripts/build_setup_map.py                      # the map counts skills too
```

Where a skill belongs — here, locally, or in the builder — and how to write its description:
`rules/on-demand/setup-rules.md`.
To write one to the shape both tools follow, and test it before relying on it: the `project-skill`
skill.

### Your own rules and skills

```
.agents/.local/
├── rules/LOADER.md    your loader, read after the shared one
├── rules/always-on/   read every session, after the shared always-on rules
├── rules/on-demand/   read when a row in your LOADER.md says to
└── skills/            your own skills — drop a folder in, then run the link script
```

A local rule or skill adds to the shared ones and never replaces one with the same name. The link
script lists a local skill's links in `.git/info/exclude`, so they never reach a commit.

### Checking the setup

Ask any agent to "validate the setup". `project-validate` reads the rules, skills, templates and spec
process, tests them against `setup-constitution-rules.md`, and reports a score, what contradicts, what
costs too many words, what could go and what's left over — each fix as a small draft. It changes
nothing; you pick what to apply.

### The map

[`SETUP-MAP.html`](SETUP-MAP.html) draws the setup: what loads every session, what loads on a
loader row, and what each file costs in words. From the repository root:

```bash
open .agents/SETUP-MAP.html          # macOS — xdg-open on Linux, start on Windows
```

## Troubleshooting

- **A skill doesn't run when you expected it to** — its description matched your request loosely, or
  not at all. Invoke it by name, or add a `LOADER.md` row naming the situation.
- **Claude or Codex doesn't see a new or local skill** — Claude sees a skill only through its link in
  `.claude/skills/`, and Codex a local skill only through its link in `.agents/skills/`. Run the link script
  above.
- **A new always-on rule isn't followed** — rules load at the start of a session. Start a new one.
- **`build_setup_map.py --check` reports a file that "exists but the map never mentions it"** — a new
  rule or skill has no row in `SETUP-MAP.html`. Add one saying what it's for.

## See also

- `rules/on-demand/setup-rules.md` — the rules for changing the setup
- `builder/README.md` and `builder/BUILDER-DESIGN.md` — how the builder works and why, where its
  developer keeps it
