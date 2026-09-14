# Builder development

Always-on, local — linked by `SETUP-DEV.md` while this project has the developer setup, and
unlinked when it switches back to the user setup. The setup here and `.agents/builder/` stay in step as
you work.

- **Every change to an installed copied file is made in its block too**, in the same step — the tree
  in `.agents/builder/README.md` says which block. A new rule, skill, template or script is added to
  both; a deleted one is deleted from both.
- **A form's shape goes to its `.seed.` block** — a section, a question, fixed text. This project's
  answers never do.
- **The constitution's source is `.agents/builder/CONSTITUTION.md`** — an edit to the installed
  `setup-constitution-rules.md` is made there too, word for word; its seed stays a placeholder.
- **What the change means for the builder goes with it** — the README tree for a new or moved block,
  `BUILDER-DESIGN.md` for a decision about how the builder works, a `CHANGELOG.md` line for what a
  release brings.
- **Nothing naming this project goes into `.agents/builder/`.**
- **Local and by hand is the intended state.** Running `spec-sync` by hand, no CI job, no hooks —
  none of these is a gap to close or raise.
- **This project was set up once.** Updating is by hand, or by asking an AI to compare with a newer
  builder. Never suggest update tooling, or keeping the builder once the project switches back to the
  user setup.
- **Don't mention any of this.** It is part of the edit, not a step to report or ask about.
