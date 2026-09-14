# Workflow rules

The loop around writing code: naming a branch, writing a commit, reading a failure, knowing what
is actually verified. Every claim here is a fact about this repository, checked against the file
named beside it — not a recommendation.

<!--
  FILLING THIS IN (SETUP.md Step 6, or by hand later):

  This file's topics are the same everywhere — that is why the template is here rather than in a
  stack profile — but every value in it is specific to one repository, and a wrong one is worse
  than a missing one. An agent that believes the wrong test command runs the wrong thing and
  reports success.

  Evidence, per section:
    Git       — `git log --oneline -30` and `git branch -a`. Read the real subjects; do not
                impose Conventional Commits on a repo that has never used them.
    CI        — the pipeline file itself (.github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile).
                List the jobs that gate a pull/merge request, and the exact command each runs.
    Gaps      — which modules or packages have tests that CI never runs. This is the part nobody
                writes down and everyone assumes wrongly.
    Local     — git hooks, pre-commit config, a formatter wired into the build.

  Delete any section this project genuinely has nothing for. An empty heading teaches nothing.
-->

## Git

| | |
|---|---|
| Commit subject | {{the real format, with a real example copied from `git log`}} |
| No ticket | {{what people actually write when there is no ticket — or delete this row}} |
| Branch | {{the real convention, with an example}} |
| Review unit | {{pull requests / merge requests, and how they're referenced in commits}} |
| Never stage | {{paths deliberately excluded, and where that exclusion lives}} |

Commit or push only when asked.

## What CI actually verifies

<!-- The point of this section is the gap between what the Commands table in .specs/02-tech.md implies and
     what the pipeline runs. State the narrower truth. -->

{{N}} job(s) gate a {{pull/merge}} request ({{pipeline file}}):

- **`{{job}}`** runs `{{exact command}}`. {{What that does and does not cover.}}

{{Which packages or modules have tests that never run in CI. Say plainly that a local run is the
only thing that will execute them, and give the command.}}

## When a run fails

1. Read the failure, fix the code. If the fix isn't obvious, say what failed and stop — a green
   run bought by weakening the check is worse than a red one.
2. Never loosen a lint config, a rule filter, or a test to make a run pass. Those are sensitive paths
   (`sensitive-paths-rules.md`): they need an explicit ask, with the reason.

## Local conveniences worth knowing

{{Hooks, auto-formatters, or generators that change files without being asked — anything that
  would otherwise show up as a diff nobody wrote. Delete the section if there are none.}}

## Scope of one change

Scope is `core-rules.md`'s. If part of the work turns out blocked, do the rest and say plainly what was
left out.
