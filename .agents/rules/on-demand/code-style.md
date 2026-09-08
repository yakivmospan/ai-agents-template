# Code style rules

Match the surrounding file before applying anything below — local consistency wins.

| Rule | Detail |
|---|---|
| Clean Code | Small, single-purpose functions; names that reveal intent without needing a comment; minimize nesting and side effects. |
| No dead code | No commented-out blocks, no speculative "for later" abstractions — the case of KISS (see core.md) most worth catching in review. |
| Handle errors deliberately | Never swallow one just to keep a signature tidy. |
| Doc comments | Use the `docs-incode` skill — don't write or review one without it. |
| New dependency → say so first | Never add one silently. |
| This project | {{CODE_STYLE_RULES — 3-6 concrete rules with evidence from the codebase, e.g. "no business logic in UI components", "all IO goes through the repository layer", "prefer immutable data classes", "public API returns Result<T>, never throws"}} |
| Anti-patterns to reject | {{STACK_SPECIFIC_ANTIPATTERNS — e.g. "unstable Compose params causing recomposition", "N+1 queries in serializers", "useEffect without dependency array"}} |
