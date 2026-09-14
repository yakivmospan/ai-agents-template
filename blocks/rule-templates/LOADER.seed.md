# Rule loader

What loads from `.agents/rules/`, for both tools.

**Every session, before any task:** read every file in `.agents/rules/always-on/`. The folder is the
list — a file added there loads next session, a file removed stops.

**On demand:** before the work in a row, read the file it names.

| Before you… | Read |
|---|---|
| write or edit a spec's content under `.specs/` | `.agents/rules/on-demand/spec-format-rules.md` (what each section must contain) and `.agents/rules/on-demand/spec-style-rules.md` (how to phrase it) |
| start, plan, build or fold in a change under `.specs/changes/` | `.agents/rules/on-demand/spec-change-rules.md`, plus `spec-format-rules.md` and `spec-style-rules.md` for its spec files |
| write or change production code | `.agents/rules/on-demand/code-style-rules.md` |
| commit, name a branch, or read a build/lint/test failure | `.agents/rules/on-demand/workflow-rules.md` |
| add a module, move a boundary, choose between designs | `.agents/rules/on-demand/architecture-rules.md` |
| change a rule, loader, skill, agent, template, script or the map — i.e. the setup itself | `.agents/rules/on-demand/setup-rules.md` |
| write, review or change a skill's `SKILL.md` | `.agents/skills/project-skill/SKILL.md` |
| write, review or change a code comment — a doc comment or an inline one | `.agents/skills/docs-incode/SKILL.md` {{keep this row only if `docs-incode` was installed for everyone; for the user only, it goes in the local LOADER.md instead}} |
| the user asks to hand work to a new conversation, or to a context with no repo access | `.agents/skills/session-snapshot/SKILL.md` {{keep this row only if `session-snapshot` was installed for everyone; for the user only, it goes in the local LOADER.md instead}} |
| write, review or change a README or an ARCHITECTURE.md, or rename a command, path or public entry point one names | `.agents/skills/docs-readme/SKILL.md` {{keep this row only if `docs-readme` was installed for everyone; for the user only, it goes in the local LOADER.md instead}} |
