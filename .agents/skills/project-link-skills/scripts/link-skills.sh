#!/usr/bin/env bash
# Make the shared skill pool visible to Claude Code.
#
# Codex reads .agents/skills natively (it scans .agents/skills from the cwd up to the repo root).
# Claude Code reads .claude/skills — but it follows symlinks, so one link per skill is enough.
# Both require a FLAT layout (.agents/skills/<name>/SKILL.md, one level deep) — Claude Code in
# particular does not discover skills nested in subfolders at all, so related skills are grouped
# by naming convention (spec-new, spec-sync, spec-from-code, spec-to-code) rather than by folder.
#
# Where symlinks are unavailable (Windows without Developer Mode / core.symlinks=false), we write
# a forwarding stub instead: a real SKILL.md whose body tells the agent where the source lives.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SRC="$ROOT/.agents/skills"
DEST="$ROOT/.claude/skills"

[ -d "$SRC" ] || { echo "error: $SRC not found — run from inside the repo" >&2; exit 1; }
mkdir -p "$DEST"

linked=0; stubbed=0; skipped=0; pruned=0

# Prune first: a symlink or stub in .claude/skills/ with no matching source in .agents/skills/
# means that skill was renamed or removed. Leaving it behind is worse than removing it — a stale
# skill can still be invoked by name and will silently point at nothing useful.
for existing in "$DEST"/*; do
  [ -e "$existing" ] || [ -L "$existing" ] || continue
  name="$(basename "$existing")"
  [ -d "$SRC/$name" ] && continue
  if [ -L "$existing" ] || [ -f "$existing/.forwarding-stub" ]; then
    rm -rf "$existing"
    echo "prune   $name (no longer in .agents/skills/)"
    pruned=$((pruned + 1))
  fi
done

for skill_dir in "$SRC"/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  target="$DEST/$name"

  # Leave anything real that already lives there.
  if [ -e "$target" ] && [ ! -L "$target" ] && [ ! -f "$target/.forwarding-stub" ]; then
    echo "skip    $name (a real .claude/skills/$name already exists)"
    skipped=$((skipped + 1))
    continue
  fi

  rm -rf "$target"

  if ln -s "../../.agents/skills/$name" "$target" 2>/dev/null && [ -f "$target/SKILL.md" ]; then
    echo "link    $name"
    linked=$((linked + 1))
    continue
  fi

  # Symlink unsupported — write a forwarding stub carrying the real frontmatter.
  rm -rf "$target"
  mkdir -p "$target"
  touch "$target/.forwarding-stub"
  {
    awk 'BEGIN{n=0} /^---$/{n++; print; next} n<2{print} n>=2{exit}' "$skill_dir/SKILL.md"
    echo
    echo "> Forwarding stub. The real skill lives at \`.agents/skills/$name/SKILL.md\`."
    echo "> Read that file now and follow it; ignore nothing in it. Any scripts it references are"
    echo "> relative to \`.agents/skills/$name/\`, not to this directory."
  } > "$target/SKILL.md"
  echo "stub    $name (symlinks unavailable)"
  stubbed=$((stubbed + 1))
done

echo
echo "linked: $linked  stubbed: $stubbed  skipped: $skipped  pruned: $pruned"
[ "$stubbed" -gt 0 ] && echo "note: stubs cost an extra file read per invocation. To get real symlinks on Windows, enable Developer Mode and set: git config core.symlinks true"
exit 0
