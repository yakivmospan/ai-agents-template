# Spec style rules

KISS for spec content — chapters, decisions, and open questions alike. A spec is read far more
often than it's written; every extra sentence taxes every future reader, human or agent. This is
about the words: how to phrase and trim whatever section you're writing, regardless of that
section's own required shape or lifecycle rules.

## Rules, in priority order

1. **State what the reader can't get elsewhere.** If a sentence just restates the section heading,
   an AC's own Given/When/Then, or something already said elsewhere in the same file, cut it — link
   instead of repeating. Applies across files too: don't restate what a parent or referenced spec
   already says.
2. **One sentence if one sentence does it.** A paragraph is a smell — expand only when the
   requirement is genuinely non-obvious, never because more words feel more thorough.
3. **Every chapter earns its place.** If a section would be empty or near-empty, delete the whole
   heading rather than leaving a stub ("None.", "N/A", an empty list). Templates show the shape of
   a fully-fleshed spec, not a checklist to fill mechanically — `Change history` is already
   optional for this reason; the same judgment applies to every other section.
4. **Decisions state the choice, the reason, and the rejected alternative — nothing else.** No
   narrative of how the conversation got there, no hedging, no restating the problem before
   answering it.
5. **Open questions state the question and the action that resolves it — nothing else.**
   Background belongs in a linked spec or ticket, not repeated here; one clause of framing is fine,
   a paragraph of it is not.
6. **Acceptance criteria stay Given/When/Then, but each clause is one fact.** If "And" chains three
   or more clauses, that's usually two criteria wearing one AC number.
7. **No filler.** "Simply", "just", "basically", "in order to", "leverage", "robust", "seamless" —
   they cost words and carry no information. Delete them on sight.
8. **Cross-reference instead of repeating.** Point at the other spec/section
   (`contract.X`'s AC-3) rather than re-deriving or re-explaining it.
9. **Prose over ceremony.** Don't reach for a table, a nested list, or a sub-heading when one
   sentence says the same thing — structure should track genuine complexity, not habit.

## The delete test

Before finalizing any sentence, section, or chapter — *if I deleted this, would a reader lose
information they actually need?* If no, delete it. Apply this on review too: flag bloated spec
prose the same way you'd flag any other water, not as a nitpick to let slide.

## Examples

Bad (water in an Intent):
> This feature is responsible for handling the enabling and disabling of Super Eva. It manages the
> various state transitions and takes care of coordinating with the different systems involved in
> making sure everything works as expected when the user wants to turn Super Eva on or off.

Good:
> Coordinates enabling/disabling Super Eva across iFLYTEK, Navi, and the permission chain — the
> single entry point other code calls to change enablement state.

Bad (open question with the actual question buried in narrative):
> During implementation there was some discussion about what should happen when the user disables
> the feature while various things are in flight, like a blocker dialog or mid-listening, and it's
> not fully clear yet what the right behavior is here.

Good:
> - [ ] **Disable semantics** — Action: decide what `enableSuperEva(false)` tears down
>   mid-chain/mid-listening/mid-blocker-dialog, and whether the dialog auto-dismisses.

Bad (decision as a narrative):
> We talked about this for a while and initially considered giving the headless service its own
> Gradle module, but after further discussion and going back and forth, the user ultimately decided
> it should just live inside `app` permanently instead.

Good:
> - **Headless service lives in `app`** — keeps signing/build config shared with the rest of the
>   app. Rejected: a separate Gradle module, unnecessary indirection for a single consumer.
