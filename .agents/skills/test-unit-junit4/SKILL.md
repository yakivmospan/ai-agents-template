---
name: test-unit-junit4
description: Use when writing unit tests for ViewModels, repositories, interactors, or other business logic classes in a JUnit4 project — testing coroutine flows, state emissions, error handling, or mocking dependencies with mockk. Check specs/02-tech.md first: if this project actually uses JUnit5 (Jupiter), use test-unit-junit5 instead, not this one — the annotations and dispatcher setup genuinely differ, this isn't just a naming choice. Do NOT use for UI/Compose rendering tests — those test the render tree, not isolated business logic, and need different tooling.
---

# Test Unit — JUnit4

## Overview

Unit tests verify individual functions and methods in isolation. Each test covers one logical concept — happy path, error condition, or edge case — with all external dependencies mocked.

---

## Key Principles & Structure Rules

| Rule | Detail |
|------|--------|
| **Test in isolation** | Mock all external dependencies — databases, APIs, file systems |
| **Cover all code paths** | Happy path, error conditions, and edge cases |
| **Full output assertion** | Verify the complete output object, not individual fields. For example, the full UiState, the full domain model, or the complete result wrapper |
| **One assertion per concept** | Each `@Test` verifies one logical contract |
| **Table tests** | Use when the same assertion must hold across multiple inputs. Two patterns are valid — choose based on diagnostic value: **(A) Individual `@Test` functions + private helper** — when each input is a semantically distinct case (e.g. different exception types, different error states) and a failing test name alone should identify the problem. **(B) Single `@Test` with a `for` loop** — when inputs are a flat homogeneous list (e.g. a set of invalid values, a set of equivalent keys) and the assertion is structurally identical for each item; the item value itself provides sufficient failure diagnostics. Never use Pattern B when inputs produce structurally different assertions. |
| **Avoid code duplication** | Extract repetitive test logic into private helper functions. Examples: common setup for multiple test scenarios, repeated mock configurations, or shared assertion logic. Helper functions should have clear names and documentation. Always prefer DRY (Don't Repeat Yourself) — if the same setup or assertion sequence appears in 3+ tests, create a helper function. |
| **No reflection** | There must be a public API that drives the state being tested |
| **No deprecated classes** | Unless absolutely necessary |
| **No matchers on real objects** | Use full object comparison instead |
| **`@VisibleForTesting`** | If private implementation is needed for testing, propose making it `internal` |
| **Set and reset dispatcher** | Via a shared `@get:Rule` (a `TestWatcher`, e.g. `MainDispatcherRule`) that calls `Dispatchers.setMain`/`resetMain` automatically — JUnit4 has no `@BeforeEach`/`@AfterEach` to hook this into class-wide setup the way JUnit5 does, and repeating `Dispatchers.setMain` by hand in every class's `@Before` is exactly the duplication a Rule exists to avoid. Define the rule once in a shared test-utils source set (see Template). |
| **Given/When/Then comments** | In every test body |
| **When/then naming** | No camelCase, Kotlin backtick names, keep them concise |
| **Never run tests** | In agent mode — propose to validate, run, then proceed |
| **Full API surface coverage** | For classes with multiple public entry points that share underlying logic (e.g. `execute()` and `executionFlow()`), every behaviour — happy path, error, edge case — must be verified through each public entry point explicitly |
| **Orchestration, not just invocation** | When a method coordinates multiple dependencies, verify it as a whole: call order (`coVerifyOrder`), *actual* data flowing between calls (not `any()`), full state-transition sequence (not just the end value), all side effects of one call asserted together in one test, and one test per failure source showing *that* failure surfaces correctly |

---

## Tech Stack

This skill assumes JUnit4, `kotlinx-coroutines-test`, `mockk`, and robolectric — confirm against
`specs/02-tech.md`, which is the actual source of truth for this project's stack. If the framework
there is JUnit5, use `test-unit-junit5` instead; the annotations and dispatcher setup below are
genuinely different, not just relabeled.

---

## Template

A one-time shared rule, defined once in a test-utils source set — not repeated per test class:

```kotlin
@ExperimentalCoroutinesApi
class MainDispatcherRule(
    private val dispatcher: TestDispatcher = StandardTestDispatcher()
) : TestWatcher() {
    override fun starting(description: Description) {
        Dispatchers.setMain(dispatcher)
    }
    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}
```

The per-class template. `@RunWith(RobolectricTestRunner::class)` is required for Robolectric under
JUnit4 (there's no `@ExtendWith`-style opt-in the way JUnit5 has) — drop it if a given test class
doesn't need Robolectric:

```kotlin
@RunWith(RobolectricTestRunner::class)
@OptIn(ExperimentalCoroutinesApi::class)
class ExampleTemplateTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val testDispatcher = StandardTestDispatcher()
    private val testScope = TestScope(testDispatcher)

    // Mocked dependencies/constants/variables go here

    @Before
    fun setup() {
        // Initialize mocked dependencies/variables here.
        // MainDispatcherRule already called Dispatchers.setMain — don't repeat it here.
    }

    @After
    fun tearDown() {
        clearAllMocks()
        // Any additional clean ups.
        // MainDispatcherRule already calls Dispatchers.resetMain automatically.
    }

    // If possible and suitable, create default mocks to avoid duplication
    private fun successResult(output: ..) = {}
    private fun failedResult(error: Throwable) = {}
    private fun mockDefaults() {
        every { .. } returns successResult(..)
        every { .. } returns successResult(..)
    }

    @Test
    fun `when all commands succeed then returns correct value`() = runTest {
        // Given

        // When

        // Then
    }

    @Test
    fun `when command fails then it throws exception`() = runTest {
        // Given

        // When

        // Then
    }

    // Other groups follow the same logic
}
```

---

## What to Test

**Happy path** — correct output for valid inputs and successful dependencies

**Error conditions** — network failures, timeouts, unavailable resources, error propagation

**Edge cases** — empty inputs, null values, boundary conditions, concurrent access

**Orchestration** — ordering, data handoff, state transitions, multi-effect completion, and per-failure-point attribution for methods that coordinate multiple dependencies

**Scope and cancellation** — For classes that accept a `CoroutineScope`, always test: caller cancellation does not affect execution on the provided scope; app scope cancellation stops execution; callbacks and side effects still run to completion when the caller cancels; internal state is consistent after cancellation

**System behavior** — Consider how the class behaves as a component in a larger system, not just in isolation. Ask: what happens under concurrent access from multiple callers? What happens when the environment it depends on (scope, lifecycle, external state) changes or is torn down? What guarantees does it make to its collaborators when things go wrong?