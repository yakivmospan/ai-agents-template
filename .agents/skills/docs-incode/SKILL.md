---
name: docs-incode
description: Use whenever writing, reviewing, or requesting any in-code comment — KDoc, Javadoc, docstrings, header comments, or plain inline `//` comments inside a function body — for classes, functions, properties, public APIs, or implementation logic. Enforces KISS: every comment must earn its place by stating something the code alone doesn't already say. Trigger any time code is being written or edited and a comment is involved, even if the request is just "add comments," "explain this," or "document this" without mentioning style.
---

# Docs In-Code

Comments — doc comments (KDoc/Javadoc/docstrings) and inline `//` comments alike — should be short
and sharp. No water: if a sentence doesn't add information the reader can't already get from the
name, type, signature, or the code itself, cut it. A doc comment states a contract for callers; an
inline comment explains a non-obvious *why* partway through an implementation. Neither restates
what the next line of code already says — that line is right there.

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

## Inline comments follow the same rules

An inline `//` comment is judged the same way as a doc comment: rules 1-4, 6, and 7 above apply
directly — state what the code can't (a non-obvious *why*, a workaround, an edge case being
guarded against), not what it can. A comment that just narrates the next line in English
("// loop over the items", "// increment the counter") is pure water — delete it, don't rephrase
it. Most well-named, well-structured code needs zero inline comments; reach for one only where the
reasoning genuinely isn't visible in the code.

## The delete test

Before finalizing any comment — doc comment or inline: *if I deleted this line, would the reader
lose real information?* If no — delete it. This is also the standard for review: flag a comment
that fails this test the same way you'd flag any other water, not as a style nitpick to let slide.

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

Bad (inline comment narrating the obvious):
```kotlin
// loop through all users
for (user in users) {
    // check if user is active
    if (user.isActive) {
        activeUsers.add(user)
    }
}
```

Good (no comment — the code already says this):
```kotlin
for (user in users) {
    if (user.isActive) activeUsers.add(user)
}
```

Good (inline comment earns its place — explains a *why* the code can't show):
```kotlin
// Retry once: the upstream API drops ~1% of first attempts under load (see INC-4021).
val response = client.call(request) ?: client.call(request)
```
