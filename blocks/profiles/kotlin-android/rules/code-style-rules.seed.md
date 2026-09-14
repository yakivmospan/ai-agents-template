# Code style rules

Match the surrounding file before applying anything below — local consistency wins.

The usual bar is assumed, not restated: small single-purpose functions, names that reveal intent
without a comment, minimal nesting, no dead code, no commented-out blocks, no speculative
abstraction (`core-rules.md`'s KISS). What follows is only what's specific to *this* repo, where a
reasonable general-practice answer would be the wrong one here.

For commits, branches, what CI actually verifies, and what to do when a run fails: `workflow-rules.md`.

<!--
  FILLING THIS IN (SETUP.md Step 6, or by hand later):

  One row per convention, and only where a competent Kotlin developer would otherwise do something
  reasonable and wrong here. A row that restates general good practice is noise; delete it.

  Every row needs evidence — a file path, a symbol, a config key you have actually opened. A rule
  you cannot point at is a rule someone will "fix" next month.

  The topics worth checking are in ../PROFILE.builder.md's last section. Expect 3-8 real rows on a normal
  project; a table of 15 means general practice crept in. Delete every row you have no evidence
  for, including all of these examples.
-->

## This project

| Topic | Rule |
|---|---|
| Logging | {{Which façade or logger to call, with its path, and what is forbidden — `Log.d`, `println`, or reaching past the façade. If some modules deliberately don't use it, say which and why, or someone will "fix" them.}} |
| Dependency injection | {{Framework, where modules live, who calls the equivalent of `startKoin`, and whether library modules may. "No manual wiring, no second DI framework" is worth stating if true.}} |
| Coroutines | {{The rule that actually bites here — a blocking call needing an explicit dispatcher, a forbidden `runBlocking`, a scope that must be used.}} |
| State exposure | {{`StateFlow`, `LiveData`, or callbacks — one of them, named, with the others ruled out.}} |
| Visibility | {{Whether `internal` is the default, and what `public` commits you to — usually a spec obligation the moment something outside the module can reach it.}} |
| Error handling | {{The project's retry / failure-escalation pattern and where it lives, plus what it is *not* — an in-call retry is not durability.}} |
| Formatting | {{Whether the formatter runs automatically (a `preBuild` dependency, a git hook) and whether lint is advisory or a gate. If builds silently reformat, say so — it explains diffs nobody wrote.}} |
| Module dependencies | {{Point at `.specs/01-architecture.md`'s Boundaries; never restate the graph here. Say what counts as a boundary change and that it needs flagging first.}} |
