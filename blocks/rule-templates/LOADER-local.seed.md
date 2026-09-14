# Local rule loader

Rules for this checkout only — `.agents/.local/` is gitignored. Read after `.agents/rules/LOADER.md`;
these rules add to the shared ones and never replace one.

**Every session, before any task:** read every file in `.agents/.local/rules/always-on/`.

**On demand:** before the work in a row, read the file it names.

| Before you… | Read |
|---|---|

