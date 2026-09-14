#!/usr/bin/env bash
# Make every installed skill visible to both tools.
#
# Codex reads .agents/skills natively (it scans .agents/skills from the cwd up to the repo root).
# Claude Code reads .claude/skills — but it follows symlinks, so one link per skill is enough.
# Both require a FLAT layout (.agents/skills/<name>/SKILL.md, one level deep) — Claude Code in
# particular does not discover skills nested in subfolders at all, so related skills are grouped
# by naming convention (spec-*) rather than by folder.
#
# Local skills live in .agents/.local/skills/, which is gitignored. Each one also gets a link in
# .agents/skills/ — otherwise Codex never sees it — and both of its links go in .git/info/exclude,
# because a committed link into an ignored folder would be broken for everyone else.
#
# Where symlinks are unavailable (Windows without Developer Mode / core.symlinks=false), we write
# a forwarding stub instead: a real SKILL.md whose body tells the agent where the source lives.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
if [ "${1:-}" = "--repo-root" ]; then ROOT="$(cd "${2:?--repo-root needs a path}" && pwd)"; fi
SRC="$ROOT/.agents/skills"
LOCAL="$ROOT/.agents/.local/skills"
DEST="$ROOT/.claude/skills"

[ -d "$SRC" ] || { echo "error: $SRC not found — run from inside the repo" >&2; exit 1; }
mkdir -p "$DEST"

linked=0; stubbed=0; skipped=0; pruned=0

# A link or a stub this script wrote — as opposed to a real skill folder someone put there.
ours() { [ -L "$1" ] || [ -f "$1/.forwarding-stub" ]; }

# link_or_stub <link target, relative to the link> <link path> <repo-relative source folder>
# Returns 0 for a real symlink, 1 when it had to write a stub.
link_or_stub() {
  rm -rf "$2"
  if ln -s "$1" "$2" 2>/dev/null && [ -f "$2/SKILL.md" ]; then
    return 0
  fi
  rm -rf "$2"
  mkdir -p "$2"
  touch "$2/.forwarding-stub"
  {
    awk 'BEGIN{n=0} /^---$/{n++; print; next} n<2{print} n>=2{exit}' "$ROOT/$3/SKILL.md"
    echo
    echo "> Forwarding stub. The real skill lives at \`$3/SKILL.md\`."
    echo "> Read that file now and follow it; ignore nothing in it. Any scripts it references are"
    echo "> relative to \`$3/\`, not to this directory."
  } > "$2/SKILL.md"
  return 1
}

# The exclude file git reads for this checkout — a worktree's `.git` is a file, so ask git.
exclude_file() {
  local file
  file="$(cd "$ROOT" && git rev-parse --git-path info/exclude 2>/dev/null)" || return 1
  case "$file" in /*) ;; *) file="$ROOT/$file" ;; esac
  echo "$file"
}

exclude() {
  local file
  file="$(exclude_file)" || return 0
  grep -qxF "$1" "$file" 2>/dev/null && return 0
  { mkdir -p "$(dirname "$file")" && echo "$1" >> "$file"; } 2>/dev/null \
    || echo "warn    add $1 to $file by hand, so it never reaches a commit" >&2
}

unexclude() {
  local file
  file="$(exclude_file)" || return 0
  [ -f "$file" ] && grep -qxF "$1" "$file" || return 0
  { grep -vxF "$1" "$file" || true; } > "$file.tmp"
  mv "$file.tmp" "$file"
}

# Local skills first, so the main pass below links them into .claude/skills like any other.
if [ -d "$LOCAL" ]; then
  for skill_dir in "$LOCAL"/*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    name="$(basename "$skill_dir")"
    if [ -e "$SRC/$name" ] && ! ours "$SRC/$name"; then
      echo "skip    $name (a shared .agents/skills/$name exists — the local one is not linked)"
      skipped=$((skipped + 1))
      continue
    fi
    link_or_stub "../.local/skills/$name" "$SRC/$name" ".agents/.local/skills/$name" || true
    exclude "/.agents/skills/$name"
    exclude "/.claude/skills/$name"
  done
fi

# Prune: a link or stub whose source is gone means that skill was renamed or removed. Left behind,
# it can still be invoked by name and points at nothing useful. Real folders are never touched.
for existing in "$SRC"/* "$DEST"/*; do
  [ -e "$existing" ] || [ -L "$existing" ] || continue
  ours "$existing" || continue
  name="$(basename "$existing")"
  case "$existing" in
    "$SRC"/*) [ -d "$LOCAL/$name" ] && continue ;;
    *)        [ -d "$SRC/$name" ] && continue ;;
  esac
  rm -rf "$existing"
  echo "prune   $name (${existing#"$ROOT"/} — its source is gone)"
  pruned=$((pruned + 1))
done

# A skill that is shared now — a real folder, not a link — must not stay hidden from git by the
# exclude lines it had while it was local.
for skill_dir in "$SRC"/*/; do
  name="$(basename "$skill_dir")"
  ours "$SRC/$name" && continue
  unexclude "/.agents/skills/$name"
  unexclude "/.claude/skills/$name"
done

for skill_dir in "$SRC"/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  target="$DEST/$name"

  # Leave anything real that already lives there.
  if [ -e "$target" ] && ! ours "$target"; then
    echo "skip    $name (a real .claude/skills/$name already exists)"
    skipped=$((skipped + 1))
    continue
  fi

  if link_or_stub "../../.agents/skills/$name" "$target" ".agents/skills/$name"; then
    echo "link    $name"
    linked=$((linked + 1))
  else
    echo "stub    $name (symlinks unavailable)"
    stubbed=$((stubbed + 1))
  fi
done

echo
echo "linked: $linked  stubbed: $stubbed  skipped: $skipped  pruned: $pruned"
[ "$stubbed" -gt 0 ] && echo "note: stubs cost an extra file read per invocation. To get real symlinks on Windows, enable Developer Mode and set: git config core.symlinks true"
exit 0
