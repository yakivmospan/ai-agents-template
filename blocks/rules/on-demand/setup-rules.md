# Setup rules

Read before changing the setup itself — a rule, a loader, a skill, an agent, a template, a script or
the map. How the setup is used is `.agents/README.md`; how the builder works, where it's kept, is
`.agents/builder/README.md`.

| Rule | Detail |
|---|---|
| Both tools, always | A rule reaches Claude and Codex only from a file both read — `AGENTS.md`, `rules/`, a skill, a spec — or a script both run. Never depend on a Claude hook, an `@` import, `.claude/settings.json` or a Codex equivalent: the other tool silently won't follow it. Work that has to follow an edit is a step in a skill, not a hook. |
| Tier | Method and stack files are the same in every project; project-tier files are this repository's own — `.specs/`, `AGENTS.md`, `rules/LOADER.md`, `setup-constitution-rules.md`, `sensitive-paths-rules.md`, `code-style-rules.md`, `workflow-rules.md`, `.claude/settings.json`, `SETUP-MAP.html`. A sentence naming something only this repository has is project tier, however much it reads like a convention, and never goes in a method or stack file. |
| Stack profile | Holds only what the next project on that stack would want unchanged: skills about the stack's tools, the topics its `code-style-rules.md` should answer, the tool commands a permission list needs. A profile skill works in a repository with none of this setup; `PROFILE.builder.md` is the only file in a profile that names anything outside it. |
| Nothing machine-specific | No absolute paths, user names, hostnames or personal directories — in prose, links or scripts. Paths are relative to the repository root. A script finds the root itself, from its own location or `git rev-parse --show-toplevel`, and accepts `--repo-root` to override it. |
| Folders in `.agents/` | Only `rules/` and `skills/` are plain folders, and `builder/` where its developer keeps it. Machinery, personal files and generated output start with a dot. |
| Write a rule to the agent | An instruction or a fact it acts on, never a note to whoever set it up. Cite another rule by its name, never its position. A rule file's name ends in `-rules.md`. |
| Where a rule goes | For every session: a file in `rules/always-on/`, kept short, since it loads every session. For a kind of task: a file in `rules/on-demand/`, and a `LOADER.md` row saying when to read it. Only for the user: the same under `.agents/.local/rules/`. |
| Where a skill goes | Every project: the builder — `skills/` if the setup can't work without it, `profiles/general/skills/` if it's optional on any stack, `profiles/<stack>/skills/` if it's about one stack's tools. This project only: `.agents/skills/`. Only the user: `.agents/.local/skills/`. Then run `project-link-skills`. |
| A skill's description | When to use it and when not to, trigger words first: both tools match requests against it, and pass over a vague one. Writing, reviewing or testing a skill: the `project-skill` skill. |
| Skill scripts | In the skill's own `scripts/`, standard library only. |
| Optional skills stay independent | A profile skill may not rely on `.specs/`, `.agents/` or another skill being there. Naming one conditionally — "if the repository has a `.specs/` tree" — is fine. |
| Templates are skeletons | Frontmatter, headings, one worked example per repeating shape, and a one-line pointer at the rule governing each section — never the rule itself, which would drift from its source. |
| Keep the map true | After a rule or skill is added, renamed or removed, run `.agents/.scripts/build_setup_map.py --check`, and write a row for anything it reports as undescribed. |
| Keep the README true | A change to how the setup is used — a folder, a loader, a command, how a rule or skill is added — updates `.agents/README.md` in the same change. |
| Keep the specs README true | A change to how specs or changes work — in a rule, a skill or a template — updates `.specs/README.md` in the same change. The README follows the rules and skills, never the other way. |
| Optional skills stay out of shared files | No rule, skill or agent every project shares names an optional skill. Wire one in with a `LOADER.md` row saying when to read it — in `.agents/.local/rules/LOADER.md` where it was installed only for the user. |
