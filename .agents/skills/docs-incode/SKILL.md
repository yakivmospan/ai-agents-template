---
name: docs-incode
description: Use whenever writing, reviewing, or requesting in-code documentation — KDoc, Javadoc, docstrings, header comments — for classes, functions, properties, or public APIs. Enforces KISS: every doc comment must earn its place by stating something the signature alone doesn't already say. Trigger any time code is being written or edited and doc comments are involved, even if the request is just "add comments" or "document this" without mentioning style.
---

# Docs In-Code

Doc comments should be short and sharp. No water: if a sentence doesn't add
information the reader can't already get from the name, type, or signature,
cut it.

## Rules, in priority order

1. **State what the signature can't.** Contracts, invariants, side effects,
   error conditions, threading/nullability quirks, or the *why* behind a
   non-obvious decision. If none of these apply, don't write a comment at all
   — a well-named, well-typed member needs no doc.
2. **One line if one line does it.** Multi-paragraph blocks are a smell.
   Expand only when behavior is genuinely non-obvious.
3. **Never restate the name in prose.** Delete "This class represents...",
   "This function is used to...", "This is a...". Say what it does or omit it.
4. **Document behavior, not implementation.** What a caller can rely on —
   not how it happens to be built today.
5. **`@param`/`@return`/`@throws` only when non-obvious.** Skip when the
   type or name already says it.
6. **No filler adjectives or verbs.** Ban "simple", "utility", "helper",
   "handles", "manages" as stand-ins for an actual description.
7. **Justify decisions in one sentence, not a paragraph**, and only when a
   reader would otherwise ask "why is this bounded / capped / this shape?".
8. **Cross-reference instead of repeating.** Point at the related member
   (`[OtherType]`) rather than re-explaining shared behavior.
9. **Skip examples that just restate the signature.** Only add one when
   usage is genuinely non-obvious.
10. **Never leak internal implementation names into public API docs.** If a
    type/module exists specifically to hide something (a wrapped protocol, a
    vendor SDK, a codegen source), don't name that thing in the public doc —
    naming it defeats the abstraction. Internal rationale belongs in the
    internal layer's own docs or an architecture doc, not on the public
    surface consumers see.

## The delete test

Before finalizing any doc comment: *if I deleted this line, would the reader
lose real information?* If no — delete it.

## Examples

Bad (water):
```kotlin
/**
 * This is a data class that represents a personalisation item.
 * It has an id and some text.
 */
data class PersonalisationItem(val id: String, val text: String)
```

Good (public type — no mention of the internal source it's mapped from):
```kotlin
data class PersonalisationItem(val id: String, val text: String)
```
No comment needed at all here — `id`/`text` already say everything. If this
were an *internal* mapper or adapter class instead of a public model, then
naming the wrapped source would be fine, because there the reader is
expected to know the internal architecture.

Bad (vague restatement):
```kotlin
/**
 * This function is responsible for handling the connection process.
 * It will attempt to connect and manages retries as needed.
 */
fun connect()
```

Good:
```kotlin
/** Idempotent: no-op if a connection loop is already active. */
fun connect()
```

Bad (no new information at all — should have no comment):
```kotlin
/** Returns the state. */
fun getState(): State
```

Good: no comment, unless `getState()` has a contract worth stating (e.g.
"throws if not connected") — then state only that.
