---
name: project-link-skills
description: Sync .agents/skills/ into .claude/skills/ so Claude sees every skill Codex reads natively, and prune any entry whose source skill was renamed or removed. Run after adding, renaming, deleting, or editing the content of a skill, or when asked to "link/relink/sync skills". Safe to run proactively, unlike the snapshot skills — it only touches the .claude/skills/ mirror, never skill content.
---

# Project Link Skills

Wraps `.agents/scripts/link-skills.sh` (or `.ps1` on Windows) so relinking is something you ask
for — or that just happens — in the conversation, not a manual shell command.

## When to run this

- Right after you or the user adds a new folder under `.agents/skills/` with a `SKILL.md` in it.
  Do this proactively, without waiting to be asked — a newly added skill that isn't linked yet is
  invisible to Claude until this runs, and there's no reason to make the user remember to ask.
- Right after a skill under `.agents/skills/` is renamed or deleted, so the stale `.claude/skills/`
  entry gets pruned rather than left pointing at nothing.
- Whenever explicitly asked to link, relink, or sync skills.

## What to do

1. Confirm `.agents/scripts/link-skills.sh` exists — if this project predates that script (a very
   old clone of the template), say so and stop rather than guessing at a fallback.
2. Run it:
   ```bash
   bash .agents/scripts/link-skills.sh
   ```
   On a Windows environment with no `bash` available, use the PowerShell twin instead:
   ```powershell
   powershell -File .agents/scripts/link-skills.ps1
   ```
3. Read the summary line (`linked: N  stubbed: N  skipped: N  pruned: N`) and report it briefly:
    - `pruned > 0` — mention which skill(s) got removed from `.claude/skills/`, so it's clear that
      wasn't accidental.
    - `stubbed > 0` — symlinks aren't available in this environment (commonly Windows without
      Developer Mode). Mention it once; a stub still works, it just costs one extra file read per
      invocation. Suggest `git config core.symlinks true` plus enabling Developer Mode as the fix,
      but don't insist on it — the stub is a working fallback, not an error state.
    - `skipped > 0` — something already exists at that `.claude/skills/` path that isn't a symlink
      or a stub the script recognizes as its own. Flag this one explicitly; it usually means a real,
      hand-authored Claude-only skill is sitting where a synced one is expected, and silently
      overwriting it would be wrong.
4. Don't narrate the mechanics unprompted beyond that summary — this should feel like routine
   housekeeping, not a noteworthy event, unless something in step 3 needs the user's attention.
