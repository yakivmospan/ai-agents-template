# Changelog

What each builder version brings, in prose, and why — so a project comparing itself with a newer
builder by hand can decide what to take.

## 0.1.0 — unreleased

The first release: a spec-driven agent setup for Claude and Codex, installed into any project by an
agent, once.

### Setting up
- **`SETUP.md`** is the prompt that sets up a project from `builder/`, once.
  - It surveys the codebase, picks the stack profile, and offers the optional skills — for everyone
    or only for you.
  - It installs every block where the README tree says, answers each form by reading the code, and
    writes the root specs.
  - It writes the builder version to `.agents/SETUP-VERSION`, reports anything still unanswered, and
    deletes `.agents/builder/`.
- **`SETUP-DEV.md`** switches a project between the user setup and the developer setup, for the builder's developer.
  Switching in, it compares the project with the builder once, asks which way each difference goes,
  and links a local rule that makes every later setup change in the builder too — tree, design and
  changelog included. Switching back removes the rule and the builder.
- **No update step.** A project takes a newer builder by comparing it by hand, or by asking an AI to.
- **One constitution.** `CONSTITUTION.md` at the builder's root is the only source: setup copies it into
  the always-on `setup-constitution-rules.md`, and its seed holds nothing but that instruction.
- **`project-skill`** writes and reviews skills to one shape — triggers first in the description,
  non-negotiables, checkable steps and stops, a word budget its `skill_stats.py` counts — and tests a new
  skill, or a changed description or steps, with a fresh agent unless the user skips it. A changed skill
  keeps its old text and is run against it, so a fix never leaves it worse or stricter than its rule; a
  change to skills that hand work to each other keeps a copy first, walks the flows they share, and
  compares `project-validate` before and after when the user wants it.
- **`project-validate`** reviews the whole setup on request, read only: it tests the rules, skills and
  spec process against the constitution, and reports a score, contradictions, token load, what could be
  simpler and what's left over — each proposal with its reason and a small draft.
- **Free rearranging.** There is no script or manifest, so blocks can be moved between folders,
  renamed and regrouped. The README tree is the only record of where each block lands.
- **Install kind in the filename.** A file with no marker is copied, `.seed.` is a form the project
  fills in, and `.builder.` stays in the builder.
- **No copied file names an optional skill.** An optional skill is wired in by a `LOADER.md` row,
  kept only where the skill was installed.

### The spec system
- **The `.specs/` tree**: a product, architecture and tech spec, then contract and feature specs.
  Every spec declares the code it owns.
  - **`.specs/README.md`** describes the specs for any agent or person — finding the spec for a file,
    reading one, changing one — so they work as memory without this setup. It follows the rules and
    skills that define the process: a change to how specs work updates it in the same change.
  - The feature, contract and implementation-plan templates are installed, for the spec skills. The three root-spec
    templates are `.builder.` files: `SETUP.md` reads them once, and nothing needs them after.
  - `02-tech.md` holds the build, test, lint and format commands. `AGENTS.md` holds only the project's
    name, one line on what it is, and the pointer to the rule loaders.
- **Rules**:
  - `LOADER.md` in each rules folder, shared and local, saying what loads and when — `AGENTS.md`
    only points at the two;
  - `core-rules.md` and `spec-rules.md`, always on;
  - `setup-constitution-rules.md`, always on and outranking every other rule — this version is for entering
    spec-driven development in small steps, so no agent argues for strictness, while asking before a sensitive path or a destructive action
    stays;
  - `sensitive-paths-rules.md`, the files an agent must ask before touching — `.agents/rules/` among
    them, so both tools ask, not only Claude;
  - `spec-format-rules.md` and `spec-style-rules.md` — a short drafting checklist, its reasoning and
    examples kept with `spec-review` — read before writing a spec;
  - `spec-change-rules.md`, read before starting, planning, building or folding in a change;
  - `setup-rules.md`, read before changing the setup itself;
  - `architecture-rules.md`, `workflow-rules.md` and `code-style-rules.md`, read before the work they cover —
    a design proposal compares approaches only when there is a real choice.
- **Changes**: every edit to what a spec guarantees goes through `.specs/changes/<branch>/` (a second change on it: `<branch>-<topic>/`) — a whole copy
  of each spec it touches, with its why in a `## Change` section, and one `implementation-plan.md` —
  design, then tasks — only when the work needs it. It folds in by copying each spec over its place, so a spec always describes the code as it is. Work across modules gets a contract spec, and each change folds in on its
  own; deleting a story folder never deletes a change nested in it. Reports to the user use plain words, not phase or skill names.
  - A `merged` spec the code has moved past, with the code right, is corrected in place — a Change
    history row, "No ticket" when there's none — without a change. A design outside a change is agreed
    in chat and recorded in `01-architecture.md` the same way.
  - A contract's Implementation table names who takes part and their role; the features' own criteria
    say which contract criteria they carry, and a contract criterion is checked once those are, or by its own
    proof — confirming it by hand confirms them too.
  - A task is an instruction in plain words, tagged at the end with the criteria it closes, if any. A
    check only a person can make turns it into a checkpoint, so building pauses where you want to try it.
  - **Changing course is part of the flow.** A design is rewritten, with the old approach kept as a
    `Not` line saying what was learned; built work changes through a new task, since a ticked one is
    never rewritten; an edited criterion keeps its approval on the user's OK, and a task changes
    its tests or code where they no longer match. A new criterion's id is one past the highest.
  - `.agents/README.md` walks through a change's steps and who approves what, so a person new to the
    setup sees the flow without reading the rules first.
- **Every spec has a `status`**: `draft` and `approved` in a change, `merged` once folded in — so any
  single file says how far it has come. Approval is per file; approving one asks whether the rest go too. A spec written from code that already exists goes from `draft`
  straight to `merged`, since there is nothing to build. Nothing folds in unconfirmed: each unchecked
  criterion is confirmed by the user as `Source: Manual`, dropped, or the change stays open.
- **A checkbox shows its proof**: each criterion lists its proof under `Verified:` — a test file with its
  tests, or `Source: Manual` with an optional description, or a one-line `Verified: Manual` — and `[x]` means it holds at least one;
  `spec-sync` warns when the two disagree.
- **Rule files end in `-rules`**, so a rule reads as one wherever it's referenced.
- **Generated overviews stay out of git.** `.specs/.gitignore` keeps `INDEX.md`, `DECISIONS.md` and
  `OPEN-QUESTIONS.md` local, so branches never conflict on them, and they can show what only one machine
  knows, like the last `spec-verify` result.
- **Spec skills**:
  - `spec-create` starts every change — a new feature, a changed one, or code that exists — working out
    which itself, through one approval only the user gives, and corrects a stale spec in place;
  - `spec-implementation-plan` writes a change's plan with the user, the `architect` subagent proposing,
    builds from it when asked, and changes it mid-way;
  - `spec-merge` folds a change into its specs by copying them over, keeps what its plan decided, and
    deletes the folder;
  - `spec-verify` checks a spec when asked, and is offered when a task relies on one marked possibly stale.
    It runs in the background — its tests run, its code read for the rest — and records the result for `INDEX.md`;
  - `spec-review` checks specs against the style rules;
  - `spec-sync` generates `INDEX.md`, `DECISIONS.md` and `OPEN-QUESTIONS.md` — helpers, where the specs
    win any disagreement — the last two grouped by spec so a task reads only the sections it touches;
  - each spec skill opens with its non-negotiables, so the rules that stop an agent deciding on its
    own apply without following a citation.
- **`spec-sync --check`** fails only on the tree's structure — dangling globs and ids, ambiguous
  ownership, a change's spec file that can't land where it's named. The rest it reports
  without failing, among them constraints recorded as currently violated, and Change history rows too
  long to be one sentence.

### Agents
- **Agents for both tools**: `architect` reads and proposes, never edits, `runner` runs build, lint and tests and
  reports failures, and `test-writer` derives tests from acceptance criteria, finding the stack's
  testing skills in `.agents/skills/`.
- **No hooks.** Nothing runs on its own in one tool only: `spec-sync` rebuilds the spec index, and
  `build_setup_map.py` the map, as steps both tools follow.

### Profiles
- **`general`**: optional skills for any stack — `docs-incode`, `session-snapshot`,
  `project-query-dependencies`, `docs-readme` — one structure for READMEs and ARCHITECTURE.md — and
  `one-head-good-two-better`, a second look at a go-ahead with no
  agreed plan behind it.
- **`kotlin-android`**: stack detection and tool commands, a code-style form, and
  the `test-unit`, `test-integration` and `compose-create` skills.

### Personal and visual
- **Only `rules/` and `skills/` are plain folders in `.agents/`**, and `builder/` where its developer keeps it. `.local/`, `.scripts/`,
  `.templates/` and `.cache/` start with a dot.
- **`.agents/.local/`**: gitignored, and created at install with an empty `LOADER.md`.
  - It holds personal rules and skills that are never shared or synced.
  - `project-link-skills` links skills for both tools, local ones included, and keeps the local
    links out of git.
- **The setup map**: an HTML page showing what loads when, and why.
  - `build_setup_map.py` keeps it current. Its every-session total counts what really loads — `AGENTS.md`,
    `CLAUDE.md`, the loader, the always-on rules and every shared skill's description — and its spec count
    leaves out the copies inside changes.
  - Local files show in their own section, from `.agents/.cache/map-local.js`.
