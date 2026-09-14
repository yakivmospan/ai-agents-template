---
name: project-link-skills
description: Use after adding, renaming or deleting a skill under .agents/skills/, or when asked to "link/relink/sync skills" — links every skill into .claude/skills/ so Claude sees what Codex reads natively, prunes links whose skill is gone, keeps a local skill's links out of git, and refreshes the map's numbers. Safe to run proactively; never changes skill content. Not for writing a skill (project-skill).
---

# Project Link Skills

Runs `.agents/skills/project-link-skills/scripts/link-skills.sh` (`.ps1` on Windows): right after a skill
under `.agents/skills/` is added, renamed or deleted — without waiting to be asked — or when asked to
relink.

## What to do

1. Run it:
   ```bash
   bash .agents/skills/project-link-skills/scripts/link-skills.sh
   ```
   With no `bash` on Windows:
   ```powershell
   powershell -File .agents/skills/project-link-skills/scripts/link-skills.ps1
   ```
2. Report the summary line (`linked: N  stubbed: N  skipped: N  pruned: N`) in a sentence, adding only:
    - `pruned > 0` — which skills were removed, so it's clear that wasn't accidental.
    - `stubbed > 0` — symlinks aren't available here. Mention it once: a stub works, and the script
      prints the fix.
    - `skipped > 0` — something the script didn't write sits at that path: usually a hand-authored
      Claude-only skill, or a local skill with the same name as a shared one. Flag it; never overwrite it.
3. Refresh the map, which counts skills and lists local ones:
   ```bash
   python3 .agents/.scripts/build_setup_map.py
   ```
   If it reports a skill as undescribed, add its row to `.agents/SETUP-MAP.html`.
