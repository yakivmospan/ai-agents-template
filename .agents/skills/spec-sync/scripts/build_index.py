#!/usr/bin/env python3
"""Rebuild .specs/INDEX.md from spec frontmatter, and report drift.

Stdlib only — no pyyaml, no install step. Handles the subset of YAML the spec
frontmatter contract uses: scalars, inline lists, and block lists.

INDEX.md is a routing table: code path -> owning spec. Read every session.
It's entirely generated from data that already exists (frontmatter), so it can't drift the way a
hand-maintained note can: there's nothing to forget to update, because there's nothing to
hand-update. Per-spec status and completion live in the specs themselves — check the `status`
field and checkboxes in the spec you're interested in.

Usage:
    python3 build_index.py [--specs-dir .specs] [--repo-root .] [--check]

--check exits 1 if INDEX.md would change or drift was found. Use it in CI.
"""

from __future__ import annotations

import argparse
import fnmatch
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path

# Directories never reported as "unowned". Build output, tooling, and the agent setup itself.
# Skipping only affects unowned-reporting — routing is unaffected either way.
SKIP_DIRS = {
    ".git", "node_modules", "build", "dist", "out", "target", "vendor",
    ".gradle", ".idea", "__pycache__", ".venv", "venv", ".next", ".mypy_cache",
    ".pytest_cache", "coverage", ".agents", ".claude", ".codex", ".specs",
}


@dataclass
class Spec:
    path: Path
    id: str
    title: str
    parent: str | None
    status: str
    owns: list[str] = field(default_factory=list)
    related: list[str] = field(default_factory=list)
    updated: str = ""


# --------------------------------------------------------------------------- parsing


def split_frontmatter(text: str) -> str | None:
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    if end == -1:
        return None
    return text[3:end]


def unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def parse_frontmatter(block: str) -> dict[str, object]:
    """Minimal YAML: `key: scalar`, `key: [a, b]`, and block lists under `key:`."""
    data: dict[str, object] = {}
    current_key: str | None = None

    for raw in block.splitlines():
        line = raw.rstrip()
        if not line.strip() or line.strip().startswith("#"):
            continue

        stripped = line.lstrip()
        indented = len(line) - len(stripped)

        if stripped.startswith("- ") and current_key and indented > 0:
            data.setdefault(current_key, [])
            target = data[current_key]
            if isinstance(target, list):
                target.append(unquote(stripped[2:]))
            continue

        if ":" not in stripped:
            continue

        key, _, value = stripped.partition(":")
        key = key.strip()
        value = value.strip()
        current_key = key

        if not value:
            data[key] = []
        elif value.startswith("[") and value.endswith("]"):
            inner = value[1:-1].strip()
            data[key] = [unquote(p) for p in inner.split(",") if p.strip()] if inner else []
        else:
            data[key] = unquote(value)

    return data


def as_list(value: object) -> list[str]:
    if isinstance(value, list):
        return [str(v) for v in value if str(v).strip()]
    if isinstance(value, str) and value.strip() and value.strip() != "[]":
        return [value.strip()]
    return []


def load_specs(specs_dir: Path) -> tuple[list[Spec], list[str]]:
    specs: list[Spec] = []
    problems: list[str] = []

    for path in sorted(specs_dir.rglob("*.md")):
        if path.name == "INDEX.md":
            continue

        block = split_frontmatter(path.read_text(encoding="utf-8"))
        rel = path.relative_to(specs_dir.parent).as_posix()

        if block is None:
            problems.append(f"{rel}: no frontmatter block — every spec needs one")
            continue

        meta = parse_frontmatter(block)
        missing = [k for k in ("id", "title", "status") if not meta.get(k)]
        if missing:
            problems.append(f"{rel}: frontmatter missing required key(s): {', '.join(missing)}")
            continue

        parent = meta.get("parent")
        parent_str = None if parent in (None, "", "null", "~", []) else str(parent)

        specs.append(
            Spec(
                path=path,
                id=str(meta["id"]),
                title=str(meta["title"]),
                parent=parent_str,
                status=str(meta["status"]),
                owns=as_list(meta.get("owns")),
                related=as_list(meta.get("related")),
                updated=str(meta.get("updated", "")),
            )
        )

    return specs, problems


# --------------------------------------------------------------------------- checks


def glob_specificity(pattern: str) -> tuple[int, int]:
    """Higher sorts first. Fewer wildcards and more path segments = more specific."""
    return (-pattern.count("*") - 2 * pattern.count("**"), pattern.count("/"))


def iter_files(root: Path):
    """Yield every file under root, pruning SKIP_DIRS and dotdirs without descending into them."""
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for name in filenames:
            yield Path(dirpath) / name


def find_gaps(specs: list[Spec], repo_root: Path, max_depth: int = 4) -> list[str]:
    """Directories with zero spec coverage, found by actually checking which files match an
    `owns` glob — not by comparing directory name prefixes, which hides gaps nested under a
    directory that's only partially covered (e.g. `src/checkout/**` owned doesn't mean the rest
    of `src/` is; every sibling under `src/` needs checking individually).

    A directory with no coverage at all is reported and not descended into further (the whole
    subtree is the gap). A directory that's fully covered is skipped. A directory that's a mix
    gets descended into, to find exactly which subdirectories are the actual gap.
    """
    owned_patterns = [p for s in specs for p in s.owns]

    def covered(file_path: Path) -> bool:
        rel = file_path.relative_to(repo_root).as_posix()
        return any(fnmatch.fnmatch(rel, pat) for pat in owned_patterns)

    gaps: list[str] = []

    def classify(dir_path: Path, depth: int) -> None:
        rel_dir = dir_path.relative_to(repo_root).as_posix()
        all_files = list(iter_files(dir_path))
        if not all_files:
            return  # empty directory — nothing to own, nothing to report

        covered_count = sum(1 for f in all_files if covered(f))
        if covered_count == 0:
            gaps.append(f"'{rel_dir}/' has no owning spec yet")
            return
        if covered_count == len(all_files):
            return  # fully covered

        # Partially covered — descend to isolate the actual gap, unless we've gone deep enough
        # that further drilling stops being useful.
        if depth >= max_depth:
            gaps.append(f"'{rel_dir}/' is partially covered — check its subdirectories")
            return

        try:
            subdirs = sorted(
                e for e in dir_path.iterdir()
                if e.is_dir() and e.name not in SKIP_DIRS and not e.name.startswith(".")
            )
            loose_files = [e for e in dir_path.iterdir() if e.is_file()]
        except OSError:
            return

        for sub in subdirs:
            classify(sub, depth + 1)

        uncovered_loose = [f for f in loose_files if not covered(f)]
        if uncovered_loose:
            names = ", ".join(f.name for f in sorted(uncovered_loose)[:3])
            more = f" (+{len(uncovered_loose) - 3} more)" if len(uncovered_loose) > 3 else ""
            gaps.append(f"'{rel_dir}/' has uncovered file(s): {names}{more}")

    for child in sorted(repo_root.iterdir()):
        if child.is_dir() and not child.name.startswith(".") and child.name not in SKIP_DIRS:
            classify(child, 1)

    return gaps


def validate(specs: list[Spec], repo_root: Path, specs_dir: Path) -> tuple[list[str], list[str]]:
    """Returns (errors, gaps).

    Errors are always wrong, regardless of how complete the specs tree is: a dangling glob,
    a duplicate id, a cycle, ambiguous ownership. These drive --check's exit code.

    Gaps are just "no spec here yet" — the normal, expected state for most of a large or
    pre-existing codebase, especially early in adopting this. A gap is not a bug and must never
    fail CI on its own; it's informational, so incremental spec coverage (write one when a task
    actually touches that area) isn't punished for being incremental.
    """
    errors: list[str] = []
    by_id: dict[str, Spec] = {}

    for spec in specs:
        rel = spec.path.relative_to(repo_root).as_posix()
        if spec.id in by_id:
            other = by_id[spec.id].path.relative_to(repo_root).as_posix()
            errors.append(f"duplicate id '{spec.id}': {rel} and {other}")
        else:
            by_id[spec.id] = spec

    roots = [s for s in specs if s.parent is None]
    if len(roots) > 1:
        names = ", ".join(sorted(s.id for s in roots))
        errors.append(f"multiple root specs (parent: null): {names} — exactly one expected")
    if not roots and specs:
        errors.append("no root spec — one spec must have `parent: null`")

    for spec in specs:
        rel = spec.path.relative_to(repo_root).as_posix()

        if spec.parent and spec.parent not in by_id:
            errors.append(f"{rel}: parent '{spec.parent}' is not a known spec id")

        if spec.status not in {"draft", "active", "superseded"}:
            errors.append(f"{rel}: status '{spec.status}' is not draft/active/superseded")

        # cycle detection
        seen, cursor = {spec.id}, spec.parent
        while cursor and cursor in by_id:
            if cursor in seen:
                errors.append(f"{rel}: parent chain forms a cycle at '{cursor}'")
                break
            seen.add(cursor)
            cursor = by_id[cursor].parent

        for pattern in spec.owns:
            if not any(repo_root.glob(pattern)):
                errors.append(f"{rel}: owns '{pattern}' matches nothing on disk")

    # overlapping globs of identical specificity
    claims: list[tuple[str, Spec]] = [(p, s) for s in specs for p in s.owns]
    for i, (pattern_a, spec_a) in enumerate(claims):
        for pattern_b, spec_b in claims[i + 1:]:
            if spec_a.id == spec_b.id:
                continue
            if glob_specificity(pattern_a) != glob_specificity(pattern_b):
                continue
            overlap = {
                p for p in repo_root.glob(pattern_a)
            } & {
                p for p in repo_root.glob(pattern_b)
            }
            if overlap:
                errors.append(
                    f"ambiguous ownership: '{pattern_a}' ({spec_a.id}) and "
                    f"'{pattern_b}' ({spec_b.id}) both claim the same files at equal specificity"
                )

    # unowned source — a gap, not an error. See find_gaps' docstring.
    gaps = find_gaps(specs, repo_root)

    _ = specs_dir
    return errors, gaps


# --------------------------------------------------------------------------- render


def render_tree(specs: list[Spec], specs_dir: Path) -> str:
    # Links are relative to specs_dir, not repo_root: INDEX.md lives inside specs_dir, and a
    # markdown relative link resolves against the file that contains it, not the repo root.
    by_parent: dict[str | None, list[Spec]] = {}
    for spec in specs:
        by_parent.setdefault(spec.parent, []).append(spec)

    lines: list[str] = []

    def walk(parent: str | None, depth: int) -> None:
        for spec in sorted(by_parent.get(parent, []), key=lambda s: s.path.name):
            rel = spec.path.relative_to(specs_dir).as_posix()
            flag = "" if spec.status == "active" else f" _({spec.status})_"
            lines.append(f"{'  ' * depth}- [`{spec.id}`]({rel}) — {spec.title}{flag}")
            walk(spec.id, depth + 1)

    walk(None, 0)

    known = {s.id for s in specs}
    orphans = [s for s in specs if s.parent and s.parent not in known]
    for spec in orphans:
        rel = spec.path.relative_to(specs_dir).as_posix()
        lines.append(f"- [`{spec.id}`]({rel}) — {spec.title} _(orphan: unknown parent)_")

    return "\n".join(lines) or "_No specs yet._"


def render_routes(specs: list[Spec], specs_dir: Path) -> str:
    # See render_tree: links are relative to specs_dir, where INDEX.md itself lives.
    rows: list[tuple[str, Spec]] = [(p, s) for s in specs for p in s.owns]
    rows.sort(key=lambda r: glob_specificity(r[0]), reverse=True)

    if not rows:
        return "_No spec declares an `owns` glob yet._"

    out = ["| Code path | Spec | Parent |", "|---|---|---|"]
    for pattern, spec in rows:
        rel = spec.path.relative_to(specs_dir).as_posix()
        parent = f"`{spec.parent}`" if spec.parent else "—"
        out.append(f"| `{pattern}` | [`{spec.id}`]({rel}) | {parent} |")
    return "\n".join(out)


def render_index(specs: list[Spec], errors: list[str], gaps: list[str], specs_dir: Path) -> str:
    drift = (
        "\n".join(f"- {e}" for e in errors)
        if errors
        else "_None. Every spec resolves and no ownership is ambiguous._"
    )
    coverage = (
        f"{len(gaps)} area(s) have no owning spec yet — normal on a large or pre-existing "
        f"codebase, not a problem to fix in one pass. Write one when a task actually touches "
        f"that area (see `spec-new`), not proactively for its own sake.\n\n"
        + "\n".join(f"- {g}" for g in gaps)
        if gaps
        else "_Everything is covered._"
    )
    return f"""<!-- GENERATED BY THE spec-sync SKILL. DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 .agents/skills/spec-sync/scripts/build_index.py -->

# Spec index

Routing table from code path to owning spec. **Match most specific glob first** — the table is
already sorted that way, so the first row whose pattern matches your file is the owner.

If a file matches nothing here, it has no owning spec. That's expected on an incompletely-specced
codebase — say so rather than inferring requirements, and see "Not yet specced" below.

## Code → spec

{render_routes(specs, specs_dir)}

## Spec tree

{render_tree(specs, specs_dir)}

## Drift

Real problems — a dangling glob, a duplicate id, ambiguous ownership. These are bugs regardless
of how complete the specs tree is, and are what `--check` fails on.

{drift}

## Not yet specced

{coverage}
"""


# --------------------------------------------------------------------------- main


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--specs-dir", default=".specs")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--check", action="store_true", help="exit 1 on drift or stale files")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    specs_dir = (repo_root / args.specs_dir).resolve()

    if not specs_dir.is_dir():
        print(f"error: {specs_dir} does not exist", file=sys.stderr)
        return 2

    specs, parse_errors = load_specs(specs_dir)
    validation_errors, gaps = validate(specs, repo_root, specs_dir)
    errors = parse_errors + validation_errors
    index_content = render_index(specs, errors, gaps, specs_dir)

    index_path = specs_dir / "INDEX.md"
    old_index = index_path.read_text(encoding="utf-8") if index_path.exists() else ""
    changed = old_index != index_content

    if args.check:
        # Gaps never fail --check: incomplete coverage on a large or pre-existing codebase is
        # the expected state, not a defect. Only real errors and a stale INDEX.md do.
        if changed:
            print("INDEX.md is out of date — run build_index.py", file=sys.stderr)
        for error in errors:
            print(f"drift: {error}", file=sys.stderr)
        if gaps:
            print(f"({len(gaps)} area(s) not yet specced — informational, not a failure)",
                  file=sys.stderr)
        return 1 if (changed or errors) else 0

    index_path.write_text(index_content, encoding="utf-8")
    print(f"wrote {index_path.relative_to(repo_root)} — {len(specs)} spec(s)")
    if errors:
        print(f"\n{len(errors)} drift item(s):")
        for error in errors:
            print(f"  - {error}")
    if gaps:
        print(f"\n{len(gaps)} area(s) not yet specced (informational, not a failure):")
        for gap in gaps:
            print(f"  - {gap}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
