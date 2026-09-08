---
name: project-init
description: Bootstrap the whole agent setup on a repository — detect the stack, generate AGENTS.md and CLAUDE.md, create the specs/ tree from the real codebase, fill every placeholder in the rules and subagent files, and link the shared skill pool. Use once per project, on a fresh template clone or when retrofitting onto an existing codebase. Never overwrites content it did not write.
---

# Project Init

You are bootstrapping spec-driven agent setup on this repository. Work through the steps in order.
**Never overwrite a file you did not generate. Never fill a placeholder with a plausible guess.**

Two hard rules that override everything below:
- If a file already exists with real (non-`{{PLACEHOLDER}}`) content, leave it alone and report it.
- If you cannot find evidence for a value, leave the placeholder and ask. A confidently wrong
  `AGENTS.md` poisons every future session in this repo.

---

## Step 1 — Survey the repository

Detect, do not assume:

- **Stack** — read the manifest: `package.json`, `build.gradle.kts`, `build.gradle`, `pom.xml`,
  `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `*.csproj`. Note the project name field.
- **Commands** — the real ones. `scripts` in `package.json`; Gradle task names; `Makefile` or
  `justfile` targets; and above all `.github/workflows/*.yml`, which is usually ground truth for
  what actually builds, tests, and lints.
- **Test framework** — from what is installed and imported, not from ecosystem defaults.
- **Structure** — top-level source directories, skipping build output, `node_modules`, `.git`.
- **Conventions** — skim 3-5 representative source files. Only record a convention you can point at
  actual code for. Do not import best practices this codebase does not follow.
- **Sensitive paths** — build config, CI, migrations, signing keys, infra.
- **Existing agent setup** — `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.codex/`, `.cursor/rules/`,
  any existing `docs/adr/` or `specs/`. All of these change what you are allowed to write.

## Step 2 — Identify candidate features

Map source directories to candidate feature specs. A feature is a unit with its own public surface
and its own reason to change — usually a module, package, or top-level feature directory, not every
file. Aim for 3-10 candidates on a normal codebase; if you get 40, you are slicing too thin.

**On a large or long-lived codebase, do not try to reach full coverage.** Spec what you can
confidently characterize from the manifest, structure, and a representative skim — usually the
newest or most actively-touched areas, since those are what's about to be worked on anyway. Leave
everything else genuinely unspecced; that is the expected, normal state, not a shortfall to
apologize for in Step 8. Coverage grows one task at a time via `spec-new` and `spec-from-code` as
work actually touches each area — that is the intended path, not a fallback for what bootstrap
missed.

For each candidate, record: proposed slug, code glob, and one line on what it appears to do.

## Step 3 — Ask for what code cannot tell you

Present everything you inferred, then ask for the rest **in one batch**. Code can show you *what*;
it cannot show you *why*, *for whom*, or *what is deliberately excluded*. You need:

1. **Project goal** — what this is, who it's for, why it exists, and what "done" looks like.
2. **Non-goals** — what this project deliberately will not do or support.
3. **Constraints** — timeline, platform, compliance, performance budgets.
4. **Confirm the feature list** from Step 2 — corrections, merges, splits, missing ones.
5. **Anything from Step 1 you could not determine** — commands, sensitive paths, conventions.

Show your inferences alongside each question so the user is correcting rather than authoring.

## Step 4 — Generate AGENTS.md and CLAUDE.md

Neither ships with the template — nothing stale to reconcile.

- **CLAUDE.md** — if absent, create it containing exactly `@AGENTS.md`. If present, do not touch it;
  if it does not import `AGENTS.md`, flag that in Step 8.
- **AGENTS.md, absent** — generate from `.agents/templates/AGENTS.template.md`, filling every
  placeholder from Steps 1-3. Keep the result tight; it loads on every single session.
- **AGENTS.md, present** — leave all existing content untouched. Append only the sections it lacks:
  the always-on read instruction, the load-on-demand table, the spec-map section, and Working style.
  If it already documents its own delegation or instruction-loading setup, do **not** add a second
  conflicting one — flag the overlap in Step 8 and let the human consolidate.

## Step 5 — Build the specs tree

Copy from `.agents/templates/`, never write frontmatter from memory:

| Template | Destination | Fill from |
|---|---|---|
| `spec-00-brief.md` | `specs/00-brief.md` | Step 3 answers 1-3 |
| `spec-01-architecture.md` | `specs/01-architecture.md` | Step 1 structure + Step 2 features |
| `spec-02-tech.md` | `specs/02-tech.md` | Step 1 stack and commands |
| `spec-feature.md` | `specs/features/<slug>.md` | one per confirmed feature |

Current status and focus for a piece of work live inside that feature spec's own `status` field
and checkboxes — that's the only place they're tracked, and `specs/INDEX.md` is a routing table,
not a status view.

For each feature spec:
- Set `owns` to a glob you have **verified matches files on disk**.
- Set `status: draft`. You are describing existing code from the outside; a human has not confirmed
  your reading of it yet. Do not mark specs `active` on their behalf.
- Write acceptance criteria from behaviour you can actually see in the code and its tests. Where the
  intent is unclear, write it as an **Open question** rather than a criterion. Under-specifying is
  recoverable; a confident wrong requirement is not.

If the repo already has specs, ADRs, or design docs elsewhere, do not migrate them silently. List
them in Step 8 with a proposed destination and let the human decide.

Don't create story specs during bootstrap — that's a judgment call for new work, not something to
infer from existing structure. Leave it to `spec-new` later; bootstrap only needs the feature tier.

## Step 6 — Fill the placeholder files

Fill only markers that are still literally `{{...}}`:

- `.agents/rules/on-demand/code-style.md` — 3-6 real conventions with code evidence, plus real anti-patterns.
- `.agents/templates/spec-02-tech.md`'s "Testing" section (once copied to `specs/02-tech.md` in
  Step 5) — framework, test command, file location, naming convention.
- `.agents/rules/on-demand/architecture.md` — module boundary rules, if the project has modules.
- `.agents/rules/always/core.md` — `{{SENSITIVE_PATHS}}`.
- `.claude/settings.json` — test, lint, build, formatter commands and source extension. If no
  formatter is configured in the repo, delete the `PostToolUse` hook rather than inventing one.
- `.claude/agents/code-reviewer.md` **and** `.codex/agents/code-reviewer.toml` — the same checks in
  both. These files have no shared schema; each placeholder gets filled twice with identical facts.
- `.claude/agents/test-writer.md` **and** `.codex/agents/test-writer.toml` — same, for framework and
  test command.
- `architect.md` / `architect.toml` — no placeholders, leave both alone.

## Step 7 — Link the shared skill pool and build the index

```bash
bash .agents/scripts/link-skills.sh
python3 .agents/skills/spec-sync/scripts/build_index.py
```

The first symlinks `.agents/skills/*` into `.claude/skills/` so Claude sees the same skills Codex
reads natively from `.agents/skills`. If symlink creation fails (Windows without Developer Mode),
the script writes forwarding stubs instead — either outcome is fine, just report which happened.

The second generates `specs/INDEX.md`. Read the Drift section and resolve or report every item.

## Step 8 — Report

End with, in this order:

1. **Created** — files written fresh.
2. **Extended** — files appended to, and which sections were added.
3. **Left untouched** — pre-existing content you deliberately did not modify, and why.
4. **Still needs input** — every unfilled placeholder and every open question in a spec, with the
   specific question attached. This is the most important section; do not compress it.
5. **Drift** — anything `build_index.py` reported under "Drift" that you did not resolve (real
   problems: a dangling glob, ambiguous ownership). Not "Not yet specced" gaps — those are expected.
6. A reminder that `specs/features/*.md` are `draft` because they're your reading of the code, not
   the author's — and that most of the codebase is likely still unspecced by design; coverage
   grows via `spec-new` and `spec-from-code` as work touches each area, not as a scheduled task.
