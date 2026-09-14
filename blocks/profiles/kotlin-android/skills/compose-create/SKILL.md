---
name: compose-create
description: >
  Use when asked to add, create, build or update a Compose screen, component, UI layout or
  Composable function, or about Compose state hoisting, recomposition or stability annotations —
  the structure, stability, performance and accessibility rules a Compose UI follows. Not for UI
  tests, or for ViewModel logic in isolation (a unit-test skill, where the project has one).
---

# Create or Update Compose Screen / Component

Applies to any Compose UI — Jetpack Compose or Compose Multiplatform.

**Where the project already decides, follow it; where it doesn't, these rules decide.** Before
writing, look for an existing screen that already does the job — extend it rather than adding a second
— and open the nearest one to match its names and shape: `Intent`/`State` instead of `Event`/`UiState`,
how it splits stateful and stateless composables, its preview style, DI accessor, theme, side-effect
helper, spacing tokens and collection types. Correctness rules — stability, lazy keys, no backwards
writes, accessibility — apply to the code you write or change, whatever the project does; gaps in existing code
you touch are listed for the user, not fixed on the way past. Adding a library is the user's call — ask
first.

Names in the examples — `Example…`, `ItemUi`, `AppTheme`, `Spacing`, `SideEffects`, `R.string.*` — are
placeholders for the project's own. Android and Material 3 APIs are shown (`stringResource(R.string…)`,
`collectAsStateWithLifecycle`, TalkBack, Material components); Compose Multiplatform and other design
systems use their own equivalents. A project with no Compose theme gets no theme wrapper in previews.
Rules marked *(EAA)* are required where the product falls under the European Accessibility Act, and
good practice everywhere else.

## Rules

| Rule | Detail |
|------|--------|
| **Stateful and stateless split** | Every screen, and any reusable component that owns a ViewModel, has a ViewModel-connected entry point and a stateless one previews use — two overloads of one name, unless the project splits them its own way (e.g. `XScreen` + `XContent`). A screen's private sub-components take plain values and lambdas, with no ViewModel entry point. |
| **Previews** | Screens: a preview per distinct UiState variant, in the project's preview style — light and dark where the app has a dark theme (`@PreviewLightDark` where the tooling has it). Reusable components: at least one preview. Private screen-local sub-components: only if complex enough to warrant it — the parent screen preview covers simple cases. |
| **Hoist state** | State lives at the lowest common ancestor that needs it. Stop hoisting when only one composable needs the state. UI-only state (a dialog's visibility, an expanded row) stays in `rememberSaveable` unless the project keeps it in its screen state; anything the ViewModel must act on goes through an event. |
| **Pass plain values to children** | Children receive plain values, not entire state objects or `State<T>` wrappers. |
| **`onEvent` for screens** | A screen exposes `onEvent: (Event) -> Unit`. Its private sub-components take `onEvent` when they raise several events, or a plain lambda when they raise one. Never pass ViewModel references into child composables. Reusable components expose typed lambdas (`onConfirm: () -> Unit`, etc.). |
| **Single sealed Event type** | All screen interactions go through one `sealed class` via `onEvent`. Never substitute multiple callback lambdas for a ViewModel interaction boundary. |
| **UiState and Event stability** | Don't assume a sealed hierarchy is inferred stable — the compiler judges the base type, and interfaces never are. Without strong skipping, annotate UiState and Event bases `@Immutable` when every subtype is; with it, this rarely matters. |
| **Stable collections** | Check whether the project's Compose compiler uses strong skipping (on by default from Kotlin 2.0.20). With it, a composable taking `List<T>` still skips when handed the same instance — emit a new list only when its contents change. Without it, `List<T>` makes the composable unskippable: use the project's immutable collection type (`ImmutableList<T>` from kotlinx.collections.immutable is the usual one), or annotate the holding UiState class `@Immutable`; ask before adding the library. |
| **`data class` with `val` only** | All UiState and UI model types use `val` properties only. |
| **`@Immutable` vs `@Stable`** | `@Immutable`: all properties are `val`, no mutations after construction. `@Stable`: `equals()` is reliable; may mutate but notifies Compose. Never apply `@Immutable` to a mutable type. |
| **Simple lambdas by default** | Plain inline lambdas are correct in most cases. Stabilise with `remember` only when profiling shows unnecessary recomposition. In `LazyColumn`, pass the screen's `onEvent` down and put the item id in the event — avoid `remember(item.id) { { ... } }` per item. |
| **`derivedStateOf`** | Use inside `remember { }` only when a UI-local value changes less frequently than its upstream state (e.g. scroll position → button visibility). Never for ViewModel data transformations. |
| **`remember` for expensive work** | Wrap expensive computations in `remember { }` with correct keys. Never place sorting, filtering, or mapping directly inside `items {}` — it re-runs every time an item composes, which during a scroll is constantly. |
| **Lazy layout keys** | Always pass a stable `key` to `items()`. Without it, list reorders recompose every item instead of just the moved one. |
| **Lambda modifiers for frame-rate state** | When state changes every frame (scroll offset, animation), use the lambda modifier variant: `Modifier.offset { }` not `Modifier.offset(y = )`, `Modifier.drawBehind { }` not `Modifier.background()`. The read moves to a later phase — placement for `offset { }`, drawing for `drawBehind { }` — so the change no longer recomposes. |
| **No backwards writes** | Never write to a `State` object after reading it in the same composition body — causes an infinite recomposition loop. Write only in event lambdas or `LaunchedEffect`. |
| **Side effects** | Collect one-off effects in the public overload only — through the project's side-effect helper where it has one, otherwise a lifecycle-aware collection in a `LaunchedEffect`. Never pass the effects flow down the tree. Concrete handlers go in `private suspend fun`s. |
| **Modifier convention** | `modifier: Modifier = Modifier` after required parameters, before optional styling. |
| **Dimensions** | Use the project's spacing or design-system tokens where it has them; otherwise follow the file's existing style. |
| **Content descriptions** | Every interactive or meaningful element has a `contentDescription` describing its **purpose** (not type, not appearance). Decorative elements: `contentDescription = null`. Always use `stringResource` — no hardcoded strings. List item descriptions must be unique per item. |
| **Touch target size** | Minimum 48dp × 48dp (Material; 44pt on iOS) for every interactive element. Use `Modifier.minimumInteractiveComponentSize()` or padding to reach the minimum when the visual is smaller. |
| **Text sizes in `sp`** | Always `sp` (or `MaterialTheme.typography`) for text — never `dp`. Layouts must survive font scale 200% — check with a `fontScale = 2f` preview in the project's preview style: use `wrapContentHeight()`, not fixed heights, on text containers. |
| **Semantics: merge related elements** | Wrap logically related composables (icon + title + subtitle) with `Modifier.semantics(mergeDescendants = true) {}` so TalkBack announces them as one unit. |
| **Semantics: headings** | Mark section headings with `Modifier.semantics { heading() }`. |
| **Semantics: custom interactive state** | Custom toggles/switches must expose `role` and `stateDescription` via `Modifier.semantics { role = Role.Switch; stateDescription = "..." }`. |
| **Live regions** | Dynamic content that updates without user interaction (status messages, async results) needs `Modifier.semantics { liveRegion = LiveRegionMode.Polite }`. |
| **Keyboard / Switch Access focus** | All interactive elements must be focusable and reachable in logical composition order. Custom dialogs trap focus while open (Material dialogs on Android already do). After a dialog closes, restore focus to a sensible element when one still exists, via `FocusRequester.requestFocus()`. |
| **Colour alone** | Never convey information by colour alone — always pair with icon, label, or shape. |
| **Colour contrast (EAA)** | Normal text (< 18sp, or < 14sp bold): ≥ 4.5:1. Large text (≥ 18sp, or ≥ 14sp bold): ≥ 3:1. UI component boundaries and meaningful graphics: ≥ 3:1. Check all interactive states; disabled components are exempt. |
| **Flashing (EAA)** | Nothing may flash more than 3 times per second (WCAG 2.3.1). |
| **Session timeouts (EAA)** | Warn before session expiry; give ≥ 20 seconds to extend. Auto-advancing content must be pausable (WCAG 2.2.1). |
| **Form errors (EAA)** | Errors identified in text (not colour alone) with a correction suggestion. Error state announced via `Modifier.semantics { error("...") }` or a live region (WCAG 3.3.1 / 3.3.3). |
| **Gesture alternatives (EAA)** | Every multi-point or path-based gesture (swipe, pinch, drag) must have a single-pointer alternative (WCAG 2.5.1). |

---

## Two-Overload Pattern

```kotlin
// Public — ViewModel-connected.
@Composable
fun ExampleScreen(
    modifier: Modifier = Modifier,
    viewModel: ExampleViewModel = koinViewModel(), // the project's DI accessor
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    // The project's side-effect helper, or a lifecycle-aware collection in a LaunchedEffect.
    SideEffects(viewModel.sideEffects) { effect ->
        when (effect) {
            is ExampleSideEffect.NavigateTo -> { /* handle */ }
        }
    }
    ExampleScreen(state = state, onEvent = viewModel::onEvent, modifier = modifier)
}

// Private — stateless, Preview-friendly.
@Composable
private fun ExampleScreen(
    state: ExampleUiState,
    onEvent: (ExampleEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (state) {
        ExampleUiState.Loading   -> LoadingContent(modifier)
        is ExampleUiState.Loaded -> LoadedContent(items = state.items, onEvent = onEvent, modifier = modifier)
        ExampleUiState.Error     -> ErrorContent(onRetry = { onEvent(ExampleEvent.RetryClicked) }, modifier = modifier)
    }
}
```

### Non-obvious semantics APIs

```kotlin
// Merge related elements into one TalkBack announcement.
Row(modifier = Modifier.semantics(mergeDescendants = true) {}) { ... }

// Mark a heading so TalkBack users can jump between sections.
Text(modifier = Modifier.semantics { heading() }, ...)

// Expose state on a custom toggle. Strings are resolved outside the semantics block.
val enabledLabel = stringResource(R.string.state_enabled)
Box(modifier = Modifier.semantics { role = Role.Switch; stateDescription = enabledLabel })

// Announce dynamic content updates automatically.
Text(modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite }, ...)

// Announce form field errors.
val emailError = stringResource(R.string.error_invalid_email)
OutlinedTextField(modifier = Modifier.semantics { error(emailError) }, ...)
```

---

## Template

```kotlin
// Placeholders throughout — see the note at the top. ImmutableList / persistentListOf come from
// kotlinx.collections.immutable; use the project's own collection type if it has one.

// ── UiState & Events ──────────────────────────────────────────────────────────

sealed class ExampleUiState {
    data object Loading : ExampleUiState()
    data class Loaded(val items: ImmutableList<ItemUi>) : ExampleUiState()
    data object Error : ExampleUiState()
}

sealed class ExampleEvent {
    data class ItemClicked(val id: String) : ExampleEvent()
    data object RetryClicked : ExampleEvent()
}

// ── Public overload ───────────────────────────────────────────────────────────

@Composable
fun ExampleScreen(
    modifier: Modifier = Modifier,
    viewModel: ExampleViewModel = koinViewModel(), // the project's DI accessor
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    SideEffects(viewModel.sideEffects) { /* handle side effects */ } // the project's helper
    ExampleScreen(state = state, onEvent = viewModel::onEvent, modifier = modifier)
}

// ── Private overload ──────────────────────────────────────────────────────────

@Composable
private fun ExampleScreen(
    state: ExampleUiState,
    onEvent: (ExampleEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (state) {
        ExampleUiState.Loading   -> LoadingContent(modifier)
        is ExampleUiState.Loaded -> LoadedContent(items = state.items, onEvent = onEvent, modifier = modifier)
        ExampleUiState.Error     -> ErrorContent(onRetry = { onEvent(ExampleEvent.RetryClicked) }, modifier = modifier)
    }
}

// ── Sub-components ────────────────────────────────────────────────────────────

@Composable
private fun LoadingContent(modifier: Modifier = Modifier) {
    val loadingLabel = stringResource(R.string.loading)
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(modifier = Modifier.semantics { contentDescription = loadingLabel })
    }
}

@Composable
private fun LoadedContent(
    items: ImmutableList<ItemUi>,
    onEvent: (ExampleEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    LazyColumn(modifier = modifier) {
        items(items, key = { it.id }) { item ->
            ItemRow(item = item, onEvent = onEvent)
        }
    }
}

@Composable
private fun ItemRow(
    item: ItemUi,
    onEvent: (ExampleEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable { onEvent(ExampleEvent.ItemClicked(item.id)) }
            .padding(horizontal = Spacing.medium, vertical = Spacing.small) // the project's tokens
            .semantics(mergeDescendants = true) {}
    ) {
        Text(item.title)
    }
}

@Composable
private fun ErrorContent(
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = stringResource(R.string.error_generic),
            modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite },
        )
        Spacer(modifier = Modifier.height(Spacing.small))
        Button(onClick = onRetry) { Text(stringResource(R.string.retry)) }
    }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@PreviewLightDark
@Composable
private fun ExampleScreenLoadingPreview() {
    AppTheme { ExampleScreen(state = ExampleUiState.Loading, onEvent = {}) }
}

@PreviewLightDark
@Composable
private fun ExampleScreenLoadedPreview() {
    AppTheme {
        ExampleScreen(
            state = ExampleUiState.Loaded(
                items = persistentListOf(
                    ItemUi(id = "1", title = "Item One"),
                    ItemUi(id = "2", title = "Item Two"),
                )
            ),
            onEvent = {},
        )
    }
}

@PreviewLightDark
@Composable
private fun ExampleScreenErrorPreview() {
    AppTheme { ExampleScreen(state = ExampleUiState.Error, onEvent = {}) }
}

@Preview(fontScale = 2f, name = "Large font")
@Composable
private fun ExampleScreenLargeFontPreview() {
    AppTheme {
        ExampleScreen(
            state = ExampleUiState.Loaded(items = persistentListOf(ItemUi("1", "Item One"))),
            onEvent = {},
        )
    }
}
```

---

## Checklist

**Architecture**
- [ ] Checked for an existing screen doing the job; names and shape match the nearest existing screen
- [ ] Every screen has a ViewModel-connected entry point and a stateless one; private sub-components take plain values and lambdas
- [ ] Side effects collected once, in the public overload, through the project's helper where it has one

**State & events**
- [ ] `onEvent: (Event) -> Unit` everywhere; no ViewModel references below the public overload
- [ ] Children receive plain values, not state objects or `State<T>`
- [ ] State hoisted to lowest common ancestor only

**Stability**
- [ ] UiState and Event stability checked, not assumed; `@Immutable` where strong skipping is off and every subtype is immutable
- [ ] All UI model `data class` types use `val` only
- [ ] Collections use the project's immutable type, or the holding class is `@Immutable`

**Performance**
- [ ] Simple lambdas by default; `remember` only where profiling justifies it
- [ ] `LazyColumn` items get the screen's `onEvent`, with the id in the event; no per-item `remember` allocations
- [ ] `derivedStateOf` used only for UI-local derived state, not ViewModel data
- [ ] Expensive computations and list transformations wrapped in `remember`; none inside `items {}`
- [ ] Every `LazyColumn` / `LazyRow` `items()` call has a stable `key`
- [ ] Frame-rate state (animation, scroll offset) read via lambda modifiers
- [ ] No backwards writes

**Previews**
- [ ] Screens: a preview per UiState variant, in the project's style; layout checked at `fontScale = 2f`
- [ ] Reusable components: at least one preview
- [ ] Private sub-components: preview only if complexity warrants it

**Accessibility**
- [ ] Every interactive/meaningful element has a `contentDescription` (purpose, not type); decorative elements have `null`
- [ ] All `contentDescription` strings use `stringResource`; list descriptions are unique per item
- [ ] Every interactive element meets 48dp × 48dp minimum touch target
- [ ] All text in `sp` or `MaterialTheme.typography`; text containers use `wrapContentHeight` not fixed heights
- [ ] Logically related elements use `semantics(mergeDescendants = true)`
- [ ] Section headings marked with `semantics { heading() }`
- [ ] Custom interactive elements expose `role` and `stateDescription` via semantics
- [ ] Dynamic content updates use `liveRegion = LiveRegionMode.Polite`
- [ ] All interactive elements keyboard/Switch Access focusable; dialogs trap and restore focus
- [ ] Information never conveyed by colour alone
- [ ] Normal text contrast ≥ 4.5:1; large text ≥ 3:1; UI boundaries and meaningful graphics ≥ 3:1 (all states; disabled exempt)
- [ ] Nothing flashes > 3 times/second
- [ ] Session timeouts give ≥ 20s to extend; auto-advancing content is pausable
- [ ] Form errors identified in text with correction suggestion; announced via `semantics { error(...) }`
- [ ] Every swipe/pinch/drag gesture has a single-pointer alternative

**Misc**
- [ ] Dimensions use the project's tokens where it has them