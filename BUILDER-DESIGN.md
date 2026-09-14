# Builder design

## Intent
A template of the agent setup. Drop `builder/` into a project, ask an agent to set it up, and get
rules, skills, spec scaffolding and the setup map shaped to that project, once. Its developer tests
it inside real projects with `SETUP-DEV.md`; releases will live in their own repository.

This file holds why the builder works the way it does, and what has to hold before it is released.
How it works — where every block lands, filename markers, who gets which block — is `README.md`. Everything here yields to `CONSTITUTION.md`, and a decision that makes adoption harder is revisited under it, not defended.

## Constraints
- **Nothing under `blocks/` names a project, and a file is either copied or seeded, never both** —
  when a copied file needs a project value, move the value into a form. A copied file holding one
  project's value needs a hand merge on every improvement.
- **Never overwrite; delete only the builder** — install leaves an existing different file and
  reports it, and a setup prompt deletes nothing but `.agents/builder/`.

## Decisions

### Structure
- **Installed files are copies; only skill links, and the developer rule's link, point elsewhere**
  - **Instead of** symlinks from the project into the builder, for the developer too
  - **Because** `builder/` has to be removable without breaking a project, and a developer moves
    between the developer and the user setup by adding or deleting that folder. The developer rule exists only
    while the builder does, so its link can't drift from its block, and stops loading if the builder goes
- **In `.agents/`, only `rules/` and `skills/` are plain folders; the rest start with a dot**
  - **Instead of** `local/`, `scripts/` and `templates/` beside them
  - **Because** rules and skills are what anyone browses; the rest is machinery, personal files or
    generated output, and a dot keeps it out of the way. `builder/` stays plain where its developer keeps it
- **Rule files end in `-rules`**
  - **Instead of** bare names like `architecture.md` and `workflow.md`
  - **Because** a rule reads as one wherever it's referenced, and `architecture-rules.md` can't be
    mistaken for the `01-architecture.md` spec
- **Blocks sit one level down, in `builder/blocks/`**
  - **Instead of** `builder/skills/` and `builder/rules/`
  - **Because** those match every skill and rule glob alongside `.agents/`
- **The folder decides who gets a skill: `blocks/skills/` always, `profiles/general/` optionally on any
  stack, `profiles/<stack>/` optionally on one**
  - **Instead of** `skills/mandatory/` + `skills/optional/`, a `required` flag, or a `stacks/` folder
  - **Because** a flag beside a folder can contradict it, and moving the folder is the whole change
- **A profile's skills are listed only by its `skills/` folder**
  - **Instead of** a skills table in each profile file, and a `general` profile file holding only
    that table
  - **Because** the folder and each skill's own description already say it, and a table beside
    them drifts
- **A script lives in the skill that uses it; `blocks/scripts/` holds only scripts no skill owns**
  - **Instead of** one shared scripts folder
  - **Because** permission paths in `.claude/settings.json` point into the skills
- **A profile installs only its chosen skills; the profile and its forms stay in the builder**
  - **Instead of** `.agents/PROFILE.md`, `.agents/stack/<name>/` with the code-style template, or
    the AGENTS, workflow and settings templates in `.agents/.templates/`
  - **Because** only `SETUP.md` reads a profile or a form; in a project it would be a leftover.
    `test-writer` finds the testing skills by reading `.agents/skills/`
- **One README for the installed setup, in chapters**
  - **Instead of** separate READMEs for the stack, the profiles and `.local/`
  - **Because** they repeated each other
- **No spec-check CI job is offered in this version**
  - **Instead of** offering one at setup and recording the answer in `workflow-rules.md`, or a
    template copied into the project
  - **Because** proposing enforcement goes against `CONSTITUTION.md`
  - **Replaced 2026-09-14:** the job offered at setup; then a parked job file

### Installing
- **No script and no manifest: agents install by reading the blocks, and `README.md`'s tree
  is the only record of where each lands**
  - **Instead of** `build.py` with `manifest.toml` and a fingerprint per file; mirroring the
    project's layout inside `blocks/`; or a mapping table in a skill
  - **Because** blocks get dragged and regrouped, and stored paths break under that
- **The install kind is a filename marker: `.seed.`, `.builder.`, or none for copied**
  - **Instead of** a `seeded` label in the README tree, repeated as name lists in both skills, or
    detecting `{{…}}`
  - **Because** the marker moves with the file. Copied spec templates and `spec-style-rules.md` contain
    `{{…}}` too. Copied is the unmarked kind because `SKILL.md` and script paths can't be renamed
- **An agent answers a form by reading the code**
  - **Instead of** a render step filling placeholders from stored answers
  - **Because** answers are judgement in prose (*"Timber; never `Log.d`"*), not values
- **No copied file names an optional skill or the builder: an optional skill is wired in by a
  `LOADER.md` row, and the developer's rule is a `.builder.` file only `SETUP-DEV.md` links, into `.agents/.local/`**
  - **Instead of** optional regions — `<!-- if skill:<name> -->` and `<!-- if builder -->` lines in
    copied files, trimmed at install and restored when pushing back
  - **Because** the loader already decides what an agent reads, and copied files stay identical to their blocks
- **No hooks: work that has to follow an edit is a step in a skill both tools run**
  - **Instead of** Claude hooks that rebuild the spec index and the map after an edit and load the
    code rules before the first production edit
  - **Because** a hook reaches one tool only, so every rule still had to work without it, and
    `.claude/settings.json` needed a merge kind of its own just to carry them
- **The builder writes only `.specs/README.md` and `.specs/.gitignore`; `SETUP.md` writes the root specs from `.builder.`
  templates that stay in the builder**
  - **Instead of** writing nothing under `.specs/`; seeding the three root specs from the builder, or
    installing their templates
  - **Because** the README is the same in every project and is what makes the specs readable without
    the setup, while specs are written in the project under the user's review, one template can't be
    both copied and seeded, and an installed template nothing reads again is a leftover
  - **Replaced 2026-09-14:** the builder writing nothing under `.specs/`
- **One stack per project, with no removal: `SETUP.md` refuses where `.agents/SETUP-VERSION` exists, and
  asks when two profiles match**
  - **Instead of** two stacks in one setup, or an uninstall step
  - **Because** without removal, a second install puts a second stack beside the first; changing
    stack is by hand (`README.md`)

### Updating
- **The constitution has one source — `CONSTITUTION.md` — and setup copies it into the always-on rule**
  - **Instead of** the builder's copy and the seed edited together; the seed holding the text, with
    `CONSTITUTION.md` pointing at it; or builder-only principles about setup and updates
  - **Because** one text can't drift, the builder's root is where it's looked for, and a copy — not a
    reference — survives setup deleting the builder. How the builder is set up and updated is a
    decision in this file, not a principle
  - **Replaced 2026-09-14:** a builder constitution with three setup principles, kept in step with the seed
    by hand
- **Setup runs once, and this version has no update step: a newer builder is compared by hand, or by
  an AI the user asks**
  - **Instead of** `project-update`, one skill pairing a project with a builder in both directions
  - **Because** a team entering spec-driven development runs a setup once; tooling for later versions
    waits until someone needs it
  - **Replaced 2026-09-14:** `project-update`
- **Setup is a prompt, not a skill: `SETUP.md` for a team's project, `SETUP-DEV.md` for the developer's**
  - **Instead of** a `project-init` skill
  - **Because** it runs once, from a folder deleted afterwards, so nothing needs to discover it
  - **Replaced 2026-09-14:** the `project-init` skill
- **Switching between the user and the developer setup is by hand, through `SETUP-DEV.md`; syncing
  under the developer setup is automatic, through a local always-on rule that makes every setup change in the builder too**
  - **Instead of** reconciling on every run, with the developer resolving each difference; symlinks
    from the project into the builder; or `builder-sync-rules.md`, loaded wherever the builder was kept
  - **Because** the developer wants changes in the templates, design and README as they're made, so
    differences only pile up under the user setup — resolved once, when switching to the developer setup — and a local
    rule loads for the developer alone
  - **Replaced 2026-09-14:** `builder-sync-rules.md`; then reconciling on every `SETUP-DEV.md` run
- **The project records only the builder version, in `.agents/SETUP-VERSION`**
  - **Instead of** a `BUILD.md` listing the profile, the skills taken and declined, whether the
    builder is kept and the files kept different on purpose; or a `.baseline/` copy or a
    fingerprint per file
  - **Because** the folders already show everything but the version, and a hand-kept list drifts

### Local
- **`.agents/.local/` is additive only**
  - **Instead of** local overrides of shared rules
  - **Revisit when** a real conflict appears
- **`.agents/.local/` is created at install, with an empty `LOADER.md`**
  - **Instead of** appearing with the first local skill
  - **Because** a folder that appears later is one nobody finds
- **Nothing under `.agents/.local/` is recorded or synced**
  - **Instead of** a receipt of local installs
  - **Because** the folder is the mechanism; taking a skill for everyone is how it gets updates
- **Each rules folder has its own `LOADER.md`, and `AGENTS.md` only points at the two**
  - **Instead of** `AGENTS.md` carrying the always-on instruction and the on-demand table, with
    a local on-demand rule starting with a line saying when to read it
  - **Because** each folder then says what loads from it, the same way for shared and local
    rules, and `AGENTS.md` keeps only project facts

### The map
- **The map is seeded**
  - **Instead of** copied
  - **Because** `build_setup_map.py` and people edit it per project, so a copy would always differ
- **The map is a local file, never published**
  - **Instead of** a hosted copy
  - **Because** a hosted copy goes stale the moment the local file changes, and only one of the two
    tools can push one
- **What a script writes on one machine lives in `.agents/.cache/`**
  - **Instead of** beside the personal rules and skills in `.agents/.local/`
  - **Because** `.local/` holds what a person writes, and `.cache/` what a script regenerates

### The spec lifecycle
- **The specs describe themselves: `.specs/README.md` says how to find, read and change one, following
  the rules and skills that define the process**
  - **Instead of** the process living only in `.agents/rules/` and the spec skills; or the README as the
    single source the skills point at
  - **Because** specs are memory any agent can use (`CONSTITUTION.md`), and `.agents/` may be neither
    committed nor installed — while a README written from its sources never quietly becomes one
- **Work not folded in yet lives in `.specs/changes/<branch>/` (a second one on it: `<branch>-<topic>/`) — a whole copy of each spec it touches,
  and an `implementation-plan.md` when the work needs one — and folds into `.specs/` by copying each
  spec over its place**
  - **Instead of** editing a spec ahead of the code; or Kiro-style requirements, design and tasks
    files kept per feature for good
  - **Because** a spec then always describes the code as it is, two tickets on one feature don't
    collide, and no finished task list or stale design is left for later sessions to read
- **A spec's criteria stay in the spec file**
  - **Instead of** a separate requirements file beside each spec
  - **Because** criteria outlive the change that added them, and Constraints, Pitfalls and Change
    history refer to them by id
- **Every spec has a `status`: `draft` or `approved` inside a change, `merged` everywhere else; only the
  user approves**
  - **Instead of** no `status`, with an `approved:` date in a change's `proposal.md`; `active` for the
    third, which reads as *being worked on*; or a folder per status
  - **Because** any single file then says how far it has come, to a person or any agent; the three names
    don't overlap the way `draft` once meant both *not agreed* and *being built*; and a status in a header
    moves no files
  - **Replaced 2026-09-14:** no `status`, with two `approved:` dates and four phases; then one `approved:`
    date in `proposal.md`
  - **Replaced 2026-09-15:** the third status was named `current`
- **Every way into a spec starts a change, through one skill — `spec-create` — and
  `spec-implementation-plan` and `spec-merge` finish it**
  - **Instead of** `spec-new`, `spec-update` and `spec-from-code` as three entry skills; or skills
    writing specs directly, beside a separate `change-*` skill family
  - **Because** a spec written from code is a reading the user has to confirm — already what a change
    carries. Three doors made the user pick one and collided on "create/update the spec"; the agent can
    tell the starting point from the specs and the code, asking only whether the code is already right
  - **Replaced 2026-09-13:** three entry skills, one per starting point
- **A `merged` spec the code has moved past, with the code right, is corrected in place — a Change
  history row, "No ticket" when there's none, and `updated:`**
  - **Instead of** a change folder with a copy, an approval and a fold-in for a spec that was only behind
  - **Because** nothing is being decided: the code already is what the spec should say, so one question
    to the user is the whole review, and the row keeps the history a change would have
- **A design outside a change — a new module or a moved boundary — is agreed in chat and recorded in
  `01-architecture.md`, with a Change history row and `updated:`**
  - **Instead of** opening a change only to hold a design, or an architecture-only plan file
  - **Because** chat is the simplest place to agree it, and the Decision and the row in the spec that
    owns the boundary keep what a change's plan would have
- **A change folder holds only spec files, and one `implementation-plan.md` — design, then tasks —
  when the work needs it**
  - **Instead of** a `proposal.md` beside the spec files; separate `design.md` and `tasks.md`; or the
    same files and two approvals at every size, with a contract change's `tasks.md` listing its
    sub-changes
  - **Because** each spec file already carries its why, in a `## Change` section, and its approval, in
    `status` — a proposal only repeated them. Design and tasks are both the how: most designs fit in two
    lines above the tasks they explain, and a big one grows sub-headings in the same file
  - **Replaced 2026-09-14:** every change with the same files and two approvals; then a `proposal.md`
    holding the why and the approval; then separate `design.md` and `tasks.md`
- **Changing course adds, never rewrites: a ticked task stays, rework is a new task, and an edited
  criterion keeps its approval on the user's OK**
  - **Instead of** rewriting or unticking built tasks; or any edit to an approved guarantee sending the
    spec back to `draft`
  - **Because** building is where the user tests and adapts, so the plan stays a record of what was
    tried and what was found, and an approval survives the ordinary back-and-forth. Only the user sets a
    spec back to `draft`, to stop and rethink
- **A new criterion's id is one past the highest in the spec and its open copies**
  - **Instead of** never reusing a removed id
  - **Because** the highest id is always in the file, while a removed one leaves no trace to check
    against. A removed highest id coming back is fine: a ticked task's tags are history, naming the
    criteria as they read when it was ticked
  - **Replaced 2026-09-14:** removed ids never reused
- **A spec written from code that already exists goes from `draft` straight to `merged`**
  - **Instead of** approving it, then folding it in as a second step
  - **Because** there is nothing to build: the approval is the user confirming the reading
- **Nothing folds in unconfirmed: each unchecked criterion is confirmed by the user, dropped, or keeps
  the change open**
  - **Instead of** criteria folding in unchecked, marked not confirmed yet
  - **Because** a `merged` spec describes the code as it is, so an unconfirmed criterion in it is a
    claim nobody made — and a person's word is enough, so one question settles every one of them
- **Reports to the user use plain words, not phase or skill names**
  - **Instead of** "Phase: Planning", "delta", "sub-change"
  - **Because** the lifecycle is the agent's to know; the user should never have to learn it
- **A criterion lists its proof under `Verified:` — test files with their tests, or `Source: Manual` —
  and its checkbox shows whether it has any; a spec may hold unchecked criteria**
  - **Instead of** a spec holding complete criteria only, with `--check` failing a checked box without a
    listed test or `verified:` escape; a bare checkbox with its proof optional; a `Verified: Yes/No` field beside the checkbox; flat
    `Source:`/`Tests:` fields beside a one-line `Verified:`; or a baseline ratcheting
    down unverified criteria
  - **Because** a person's word is enough (`CONSTITUTION.md`), but has to be written down to be seen at a
    glance rather than dug out of `git blame` — so a checked box with no proof is a warning, never a failure
  - **Replaced 2026-09-14:** complete, evidenced criteria only; then a bare checkbox with its proof
    optional; then flat `Source:`/`Tests:` fields beside a one-line `Verified:`
- **Work across modules gets a contract spec its features point at; each change folds in on its own**
  - **Instead of** a contract change holding a sub-change per feature, merged together
  - **Because** a story's tickets finish at different times, and gating one on another blocked finished
    work
  - **Replaced 2026-09-14:** contract changes merged together with their sub-changes
- **A contract's Implementation table names who takes part and their role; which contract criteria a
  feature carries is written once, as `(contract AC-n)` in the feature's own criteria**
  - **Instead of** a `Satisfies` column listing criteria per feature beside the same tags in the features
  - **Because** two mappings drift, and the one beside the criterion is the one updated when it changes.
    A contract criterion is checked by its own proof or once its feature criteria are; confirming it by
    hand confirms them too, since a person trying the whole flow tried each part of it
  - **Replaced 2026-09-14:** a traceability matrix in the contract's Implementation table
- **A change's spec files sit flat in its folder, one per spec, each named after the path it lands at
  (`specs.feature.logger.md`) and each the whole spec as it should read afterwards**
  - **Instead of** a delta applied section by section — ADDED, MODIFIED, REMOVED, RESOLVED; one
    requirements file holding criteria only; one target spec per change; or a `specs/` tree mirroring
    `.specs/`
  - **Because** a whole copy folds in by copying over, which any agent can do; one ticket can touch
    several specs; a file's name is where it lands; and a mirrored tree buried each spec several folders
    deep
  - **Replaced 2026-09-14:** a `specs/` tree inside each change, mirroring `.specs/`; then deltas applied
    section by section
- **One skill holds a plan's whole life — writing it, building from it, changing course — and the
  architect subagent proposes**
  - **Instead of** the architect subagent deciding, with `design.md` shaped by one paragraph; or a
    design skill and a build skill handing over to each other
  - **Because** a plan is a conversation the user has to steer and resume, and changes of course are
    frequent: a handover between two skills mid-build is where an agent skips the other skill's rules
  - **Replaced 2026-09-14:** `spec-design` writing `design.md` and `tasks.md`, and `spec-apply` building
    from them
- **Each spec skill opens with its non-negotiables, stated inline**
  - **Instead of** skills that only point at the rule files, leaving every rule one or more citations away
  - **Because** each hop is a chance the rule never loads, and the few rules that stop an agent deciding
    on its own drowned among formatting rules of equal weight. The rule files stay the source; the
    inline list is short enough to check against them
- **`DECISIONS.md` and `OPEN-QUESTIONS.md` are grouped by spec**
  - **Instead of** one whole-tree table each, read in full on every task
  - **Because** a spec's own entries already come with reading it, so a task needs only its parent
    chain's and related specs' sections — and a whole-tree table grows with coverage
- **The generated overviews are never committed — `.specs/.gitignore` keeps them local**
  - **Instead of** committing `INDEX.md`, `DECISIONS.md` and `OPEN-QUESTIONS.md` with the specs
  - **Because** every change rebuilds them, so a team on branches would conflict on nearly every merge;
    `spec-sync` rebuilds them in seconds, no spec depends on them, and a local copy can show what only
    one machine knows, like the last `spec-verify` result
- **Skill shape and testing live in a mandatory `project-skill` skill**
  - **Instead of** more rows in `setup-rules.md`, or relying on Claude's own skill-creator
  - **Because** a shape needs a template and a test procedure, which a rule table can't carry, and a
    Claude-only skill reaches one tool
- **The setup is validated by a mandatory, read-only skill run on request — `project-validate`**
  - **Instead of** a prompt kept beside `SETUP.md`, which a user install deletes with the builder; a
    scoring script; or a check that runs every session or in CI
  - **Because** judging the setup against the constitution — contradictions, what could go — takes
    reading, not a script; every project keeps the skill after install; and on request keeps its cost
    out of ordinary sessions. It proposes, never edits, and never proposes strictness
- **Each principle has one owning rule; other rules point at it, and only a skill's non-negotiables
  restate it**
  - **Instead of** the same principle restated in each rule file that touches it
  - **Because** every copy is one more place for the rules to disagree
- **`spec-style-rules.md` is a drafting checklist; the reasoning and examples live in `spec-review`'s
  `reference.md`**
  - **Instead of** one 2,800-word file loaded on every spec edit
  - **Because** polish is caught by `spec-review --fix`, offered at merge, so drafting needs the rules,
    not the essay

## Acceptance criteria

What has to hold before 0.1.0 is released. Unchecked means not yet run.

- [ ] **AC-1: `SETUP.md` sets up a project by reading alone**
  - **Given** a repository with no agent setup and `builder/` at `.agents/builder/`
  - **When** `SETUP.md` runs
  - **Then** every block lands where `README.md`'s tree says, and `LOADER.md` and the map have rows
    only for the optional skills it installed
  - **And** `.agents/SETUP-VERSION` is written, every `{{` left in a form is listed in the final
    report, and `.agents/builder/` is gone
- [ ] **AC-7: A new form needs only the README tree**
  - **Given** a new `.seed.` block, with only `README.md`'s tree updated
  - **When** `SETUP.md` runs
  - **Then** it is installed as a form, with no change to `SETUP.md`
- [ ] **AC-12: Switching to the developer setup reconciles a project once**
  - **Given** a project with the user setup from this builder, with one installed rule edited, and `builder/`
    put back at `.agents/builder/`
  - **When** `SETUP-DEV.md` runs
  - **Then** it reports that rule as the only difference and changes nothing before the developer
    chooses
  - **And** once the choice is applied, the developer rule is linked into `.agents/.local/rules/always-on/`
- [ ] **AC-13: Under the developer setup, a setup change reaches the builder as it's made**
  - **Given** a project with the developer setup, in a session started after the developer rule was linked
  - **When** an agent changes an installed rule
  - **Then** its block has the same change, with no step run or asked about
- [ ] **AC-10: Local additions show only in the map's Local section**
  - **Given** a local rule and a local skill
  - **When** the map is opened from `file://`
  - **Then** the Local section lists both, and the shared rows don't include the local skill
  - **Note:** an agent rendered it in headless Chrome during development; a person hasn't looked yet
- [x] **AC-11: Local skill links stay out of git**
  - **Given** a skill in `.agents/.local/skills/`
  - **When** `project-link-skills` runs, and again after the skill is removed
  - **Then** it is linked for both tools with both links excluded from git, and the links are then
    pruned
  - **Verified:**
    - **Source:** Manual
      - during development

## Open questions
- [ ] **How a project gets the builder once it has its own repository**
  - **Action:** decide at the move — likely versions tagged there, with `SETUP.md` explaining
    the fetch.

## References
- `README.md` — where every block lands, the filename markers, and how to set up and change
  the builder.
- `SETUP.md` and `SETUP-DEV.md` — the setup steps these decisions shape.
- `CHANGELOG.md` — what changed between versions, and why.
