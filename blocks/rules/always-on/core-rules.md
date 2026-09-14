# Core rules

Always-on.

## Ground rules

| Rule | Detail |
|---|---|
| KISS, always | Code, specs, docs, explanations. Simplest thing that satisfies the actual requirement — no speculative flexibility, no premature abstraction, no restating the obvious. |
| Specs vs. code conflict | Stop and say so before writing anything. Do not silently pick a side. Inside a change, code behind its spec files while its tasks — or, with no plan, its criteria — are still open is expected, not a conflict. |
| No invented facts | If a convention, command, or requirement isn't written down or visible in the code, ask — don't fill the gap with ecosystem defaults. |
| Scope | One feature or module per change. Touching a second one needs a stated reason first. Adding anything beyond what was asked, or unsure whether a request fits this project at all: check `.specs/00-product.md`'s Non-goals first. |
| Unsure | Say "I don't know" and name the missing input. A wrong confident answer costs more than a question. |
| Rule vs rule | Two files in this setup disagreeing — `AGENTS.md` against a skill, a rule against a template — is a bug in the setup, not a choice to make quietly. The more specific file wins for now; say which one you followed and that they conflict, so it gets fixed once instead of resolved differently every session. The constitution excepted: it always wins. |

## Every task

1. Read `.specs/README.md`, up to *Change what a spec guarantees*, if not already read this session. For each file you'll edit, find its
   owning spec by `owns` — `INDEX.md` routes it when up to date — and read it, and any copy of it in an
   open change under `.specs/changes/`. No match is normal on a partially-specced codebase, not a blocker.
   A feature or contract spec the task relies on, listed as possibly stale in `INDEX.md`: say so in
   one line, offer `spec-verify`, and carry on.
2. Before proposing an approach or explaining why something is built the way it is, read the
   Decisions that bind it — a rejected alternative leaves no trace in the source. Read those of the owning
   spec, its parent chain, its `related` specs and any pending change against them — `.specs/DECISIONS.md`
   groups them by spec; without it, read each spec's own — and all of them only when the approach cuts
   across the tree. If the task would re-decide one, say so instead of quietly deciding
   it again. Open questions work the same way: a spec's own are in the spec, and
   `.specs/OPEN-QUESTIONS.md` is the view across the tree. Work that would answer one is a question
   for the user, not a call to make while implementing.
3. Anything that adds, changes or removes what a spec guarantees, substantial enough to be worth
   finding later, starts as a change before any code, through `spec-create` — a new feature, a feature a spec
   already describes, or code no spec covers yet. It starts by
   eliciting what nobody has written down, which is the point. Coverage grows this way, one task at a time.
   A one-line fix needs none, nor does a fix that makes code meet a criterion already written, in a
   spec or an open change, nor correcting a stale spec to code that's already right — done in place, as `spec-create` walks it.
4. A module is added, a boundary moves, or there's a genuine choice between designs: design it with
   the user rather than picking an approach unilaterally — inside a change through
   `spec-implementation-plan`; outside one, in chat, with the choice recorded per `architecture-rules.md`. The `architect`
   subagent does the deep reading and comparing along the way, and proposes; the user decides.
   This is not a file count — most ordinary changes touch several files and don't need it.
5. Implement — inside a change, only when asked, through `spec-implementation-plan`.
6. New or changed public surface, when tests are wanted: delegate to the `test-writer` / `test_writer` subagent, pointing
   it at the owning spec's acceptance criteria — or the change's, inside one — and at
   `.specs/02-tech.md`'s Testing section for which framework and command actually apply.
7. Build, lint, or tests to check the result: delegate to the `runner` subagent instead
   of reading raw command output yourself.
8. Work outside a change moved something a spec states — behaviour, surface, owned paths, or
   something it records as broken or pending: update that spec alongside the code, per `spec-rules.md`'s
   *Keeping it honest*. Inside a change, edit its spec files instead. No spec existed and the task turned
   out substantial → consider `spec-create` for it now.

On Codex, any step above that hands work to a subagent or the background needs an explicit ask; without
one, do the work inline.
