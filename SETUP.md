# Setup

A prompt, run once. With this folder at `.agents/builder/` — dropped in, or unpacked from the
builder's zip — tell the agent: *Set up the agent setup here — follow `.agents/builder/SETUP.md`.*
It installs the setup, then deletes the builder.

You are setting up spec-driven agent tooling on this repository with the builder in
`.agents/builder/`. Work through the steps in order.
**Never overwrite a file you did not generate. Never fill a placeholder with a plausible guess.**

One hard rule that overrides everything below: if you cannot find evidence for a value, leave the
placeholder and ask. A confidently wrong `AGENTS.md` poisons every future session in this repo.

You do all of it: copying blocks into place, linking
skills — and the judgement: which profile, which skills, and every answer that has to come from
reading this codebase. Where each block lands is the tree in `.agents/builder/README.md`; nothing
else maps it.

---

## Step 0 — Make sure this is a first setup

If `.agents/SETUP-VERSION` exists, stop. The project is already set up: this version has no update
step — a newer builder is compared by hand — and starting over is *Change stack* in
`.agents/builder/README.md`. Say so, and do neither unless asked.

## Step 1 — Survey the repository

Detect, do not assume:

- **Stack** — read the manifest: `package.json`, `build.gradle.kts`, `build.gradle`, `pom.xml`,
  `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `*.csproj`. Note the project name field.
- **Commands** — the real ones. `scripts` in `package.json`; Gradle task names; `Makefile` or
  `justfile` targets; and above all the CI pipeline file, which is usually ground truth for what
  actually builds, tests, and lints.
- **Test framework** — from what is installed and imported, not from ecosystem defaults.
- **Structure** — top-level source directories, skipping build output, `node_modules`, `.git`.
- **Conventions** — skim 3-5 representative source files. Only record a convention you can point at
  actual code for. Do not import best practices this codebase does not follow.
- **Existing documentation** — `README.md`, `docs/**`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, or
  similar. Read these before asking Step 4's questions — a goal, non-goal, or constraint already
  written down there is evidence to cite, not something to ask the user again.
- **Sensitive paths** — build config, CI, migrations, signing keys, infra, lint and formatter config, code generators.
- **Existing agent setup** — `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.codex/`, `.cursor/rules/`,
  any existing `docs/adr/` or `.specs/`. All of these change what you are allowed to write.
- **Whether the setup will be committed** — is `.agents/` or `.specs/` in `.gitignore` or
  `.git/info/exclude`? `workflow-rules.md` records it (Step 6).

## Step 2 — Choose the stack profile

`.agents/builder/blocks/profiles/` holds one folder per stack, plus `general/`, which is not a stack.
A stack profile is what is true of a *stack* rather than of a project: the skills built around its
test runner and UI framework, the tool commands a
permission list needs, and the topics a `code-style-rules.md` on that stack must answer. Getting this
wrong is how a Python service ends up with Kotlin skills presented as house rules, so it is decided
before anything is installed.

1. Read each stack profile's **Detection** section — every `profiles/*/PROFILE.builder.md` — against what
   Step 1 found.
2. **One matches** — use it.
3. **More than one matches** — the repository spans two stacks. Ask which one this setup is for;
   one setup holds one stack.
4. **None matches** — write one in `.agents/builder/blocks/profiles/<name>/`. Copy the nearest
   `PROFILE.builder.md` as a shape and replace every value from evidence in this repository:
   detection rule, real tool commands, and the
   code-style topics that actually bite on this stack. Add `rules/code-style-rules.seed.md` in the
   shape of an existing one. Leave `skills/` empty rather than translating another stack's skills;
   a test skill for a runner you have not read is worse than none. A skill you do add must work in a
   repository with none of this setup — no reliance on `.specs/`, `.agents/` or another skill.

Say which profile you chose and why in the report. If you wrote a new one, say what is still empty
in it.

## Step 3 — Identify candidate features

Map source directories to candidate feature specs. A feature is a unit with its own public surface
and its own reason to change — usually a module, package, or top-level feature directory, not every
file. Aim for 3-10 candidates on a normal codebase; if you get 40, you are slicing too thin.

**On a large or long-lived codebase, do not try to reach full coverage.** Spec what you can
confidently characterize from the manifest, structure, and a representative skim — usually the
newest or most actively-touched areas, since those are what's about to be worked on anyway. Leave
everything else genuinely unspecced; that is the expected, normal state, not a shortfall to
apologize for in the report. Coverage grows one task at a time via `spec-create`
as work actually touches each area — that is the intended path, not a fallback for what setup
missed.

For each candidate, record: proposed slug, code glob, and one line on what it appears to do.

## Step 4 — Ask for what code cannot tell you

Present everything you inferred, then ask for the rest **in one batch**. Code can show you *what*;
it cannot show you *why*, *for whom*, or *what is deliberately excluded*. You need:

1. **Optional skills** — every skill folder under `profiles/general/skills/` and the chosen stack's
   `skills/`, as its own `SKILL.md` describes it, each with your recommendation
   from Step 1 (no Compose code → no `compose-create`). For each: **skip**, **everyone** (the shared
   setup), or **only me** — copied once into gitignored `.agents/.local/skills/`.
2. **Project goal** — what this is, who it's for, why it exists, and what "done" looks like.
3. **Non-goals** — what this project deliberately will not do or support.
4. **Constraints** — timeline, platform, compliance, performance budgets.
5. **Confirm the feature list** from Step 3 — corrections, merges, splits, missing ones.
6. **Anything from Step 1 you could not determine** — commands, sensitive paths, conventions.

Show your inferences alongside each question so the user is correcting rather than authoring.

## Step 5 — Install

Do this with `.agents/builder/` still in place — Step 9 deletes it. Walk `blocks/` and put every file
where the tree in `.agents/builder/README.md` says it lands.
How to install it is in its filename — a marker just before the extension, dropped from the
destination name (`AGENTS.seed.md` lands as `AGENTS.md`):

- **No marker — copied.** Byte for byte. A destination that already exists with different content
  is **left**: don't overwrite it, and list it in the report.
- **`.seed.` — a form.** Only if missing; an existing destination is **kept** — it is the project's,
  and Step 6 says what may be added to it.
- **`.builder.` — not installed.** Read here, like a stack's `PROFILE.builder.md`.

Never infer the kind from `{{…}}`: the spec templates and `spec-style-rules.md` are copied and keep theirs
on purpose.
- **The profile** — its chosen skills, and its code-style form by the tree: each optional skill
  chosen for everyone, from `profiles/general/skills/` or `profiles/<stack>/skills/`, into
  `.agents/skills/`. A skill chosen "only me" goes into `.agents/.local/skills/` instead, once — it is
  the user's from then on.
- **Optional skills** — no copied file names one. `LOADER.md`'s rows for optional skills are form
  questions: keep a row only for a skill that went to everyone, and put the row in
  `.agents/.local/rules/LOADER.md` instead for one that went only to the user. In the map, delete
  the rows and boxes of every optional skill not installed for everyone.
- **Not installed** — everything outside `blocks/`, and every `.builder.` file.

Then:

- Create `.agents/.local/rules/always-on/`, `.agents/.local/rules/on-demand/` and `.agents/.local/skills/`.
- Link the skills: `bash .agents/skills/project-link-skills/scripts/link-skills.sh`. `stubbed` in its
  summary means symlinks are unavailable here — fine; mention it once.
- Write `.agents/SETUP-VERSION`: one line, the builder's `VERSION`. Nothing else is recorded — the
  folders show what was installed.
- Search every seeded file for `{{`. That list is Step 6's worklist. Installed spec templates and
  `spec-style-rules.md` keep placeholders on purpose; don't count them.

## Step 6 — Answer the seeded files

Fill only markers that are still literally `{{...}}`, and delete the filling instructions (an HTML
comment explaining how to fill the file, a `_comment` key) once a file is answered:

- **`AGENTS.md`** — the project name and one-line description, nothing more; it loads on every
  session. Stack and commands go in `02-tech.md`, structure in `01-architecture.md` (Step 7). If `AGENTS.md` already existed (`kept`), leave its content alone and append only what it
  lacks: the instruction to read `.agents/rules/LOADER.md` and the local loader. If it already documents its
  own delegation or instruction-loading setup, do **not** add a second one — flag the overlap in
  the report and let the human consolidate. `CLAUDE.md` should contain `@AGENTS.md`; if an existing
  one doesn't import it, flag that.
- **`.agents/rules/LOADER.md`** — keep only the optional-skill rows Step 5 kept. If the project already
  had on-demand rules of its own, add a row for each.
- **`.agents/rules/always-on/setup-constitution-rules.md`** — replace its placeholder with `.agents/builder/CONSTITUTION.md`, word for word. Nothing else to answer.
- **`.agents/rules/always-on/sensitive-paths-rules.md`** — only paths that exist: build config, CI, signing
  keys, local machine config, lint and formatter config, migrations, infra, code generators.
- **`.agents/rules/on-demand/code-style-rules.md`** — 3-6 real conventions with code evidence, plus real
  anti-patterns. Delete every row you have no evidence for; a table of general good practice is
  worse than a short one.
- **`.agents/rules/on-demand/workflow-rules.md`** — from `git log`, the pipeline file, and any git hooks
  or formatters wired into the build. The section that matters most is which tests CI *doesn't* run: nobody writes
  that down and everyone assumes wrongly. Say whether `.agents/` and `.specs/` are committed — other
  files point here for that answer.
- **`.claude/settings.json`** — the `permissions` placeholders, from the profile's *Tool commands*
  table plus Step 1's findings, then delete `_comment`. If the file already existed, it was kept —
  leave it alone.
- **`.specs/00-product.md`**, **`01-architecture.md`**, **`02-tech.md`** — Step 7.

`.agents/rules/on-demand/architecture-rules.md` is copied, not seeded — **leave it alone, and never add
this project's module boundaries to it.** It is method; the boundary graph is state, and
`.specs/01-architecture.md`'s Boundaries section owns it.

## Step 7 — Build the specs tree

Create every spec from a template — the builder writes only `.specs/README.md` and `.specs/.gitignore`, in Step 5, and
frontmatter is never written from memory. The root specs' templates are `.builder.` files read from the builder,
since nothing needs them after this step; the feature template is the one Step 5 installed for
`spec-create`. Copy a template only where the spec doesn't exist yet:

| File | Copy of | Fill from |
|---|---|---|
| `.specs/00-product.md` | `.agents/builder/blocks/spec-templates/spec-00-product.builder.md` | Step 4 answers 2-4 |
| `.specs/01-architecture.md` | `.agents/builder/blocks/spec-templates/spec-01-architecture.builder.md` | Step 1 structure + Step 3 features |
| `.specs/02-tech.md` | `.agents/builder/blocks/spec-templates/spec-02-tech.builder.md` | Step 1 stack and commands. Its Testing section — framework, test command, file location, naming convention — is what the `test-writer` subagent reads, so leave nothing out |
| `.specs/changes/<branch name>-<feature slug>/` | `.agents/.templates/spec-feature.md`, as `specs.feature.<slug>.md` with `status: draft` | one `spec-create` change per confirmed feature — it goes from `draft` to `merged` once the user confirms the reading |

A spec describes the code as it is. Work agreed or in progress lives in change folders under
`.specs/changes/`; setup writes only the feature changes above.

For each feature change:
- Set the new spec's `owns` to a glob you have **verified matches files on disk**.
- You are describing existing code from the outside, and a human has not confirmed your reading of
  it yet — Step 9's report says so; don't present it as settled.
- Write acceptance criteria from behaviour you can actually see in the code and its tests. Where the
  intent is unclear, write it as an **Open question** rather than a criterion. Under-specifying is
  recoverable; a confident wrong requirement is not.

If the repo already has specs, ADRs, or design docs elsewhere, do not migrate them silently. List
them in the report with a proposed destination and let the human decide.

Don't create contract specs during setup — that's a judgment call for new work, not something to
infer from existing structure. Leave it to `spec-create` later; setup only needs the feature tier.

## Step 8 — Index and map

```bash
python3 .agents/skills/spec-sync/scripts/build_index.py
python3 .agents/.scripts/build_setup_map.py
```

The first generates `.specs/INDEX.md`, `.specs/DECISIONS.md` and `.specs/OPEN-QUESTIONS.md`. Read
the Drift section and resolve or report every item. Unspecced areas are informational — a freshly
set-up tree has plenty.

The second refreshes the setup map's numbers and lists every rule or skill the map has no row for —
typically this project's own files. Add a row for each in `.agents/SETUP-MAP.html` saying what
it is for; that half of the map is written, not generated.

## Step 9 — Report

Delete `.agents/builder/` now. Search the seeded files and `.specs/` for `{{` once more, and end
with, in this order:

1. **Chosen** — the stack profile and why; each optional skill and whether it went to everyone or
   only the user.
2. **Created** — files written fresh.
3. **Extended** — pre-existing files appended to, and which sections were added.
4. **Left untouched** — every `kept` and `left` from Step 5, and why.
5. **Still needs input** — every `{{…}}` still left in a seeded file or a spec, and every open question in a spec, with
   the specific question attached. This is the most important section; do not compress it.
6. **Drift** — anything `build_index.py` reported under "Drift" that you did not resolve (real
   problems: a dangling glob, ambiguous ownership). Not "Not yet specced" gaps — those are expected.
7. A reminder that the feature changes under `.specs/changes/` are your reading of the code, not the
   author's, and wait for their approval — and that most of the codebase is likely still unspecced by design; coverage
   grows via `spec-create` as work touches each area, not as a scheduled task.
