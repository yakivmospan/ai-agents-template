# Spec rules

Always-on.

## On any task

| Rule | Detail |
|---|---|
| One owner per file | The most specific glob in `owns` wins — fewest wildcards, then most path segments. Two equal-specificity globs matching the same file is a bug — flag it. |
| Where a decision lives | Inside the file → kdoc; anywhere else, including a single-file decision that contradicts a project-wide rule → spec Decision (spec-style-rules' *One owner per decision* and *What was rejected*). |
| Generated files are helpers | `INDEX.md`, `DECISIONS.md` and `OPEN-QUESTIONS.md` are `spec-sync`'s output. Run it after editing specs; where one disagrees with the specs, the specs win. |

## Keeping it honest

What work outside a change owes its spec, alongside the code (`core-rules.md`'s *Every task*).

| When | Do |
|---|---|
| A test a criterion lists is renamed, moved or deleted | Update the `Source:` under that criterion's `Verified:`. |
| You fixed or changed something a spec records as broken, missing or pending — a `Currently violated`, a Pitfall, an Open question | Search `.specs/` for it and correct every line that describes it. Nothing detects this for you. |
| Deleting/moving code | Update `owns`. |
| Confirmed a spec matches its code | Set `updated` to that day — not while differences are still open. |
| A spec is behind code that's already right | On the user's yes, correct it in place — criteria without proof, or reworded, become `Source: Manual`, never one for something not built — with a Change history row (its ticket, or "No ticket") and `updated`. |
