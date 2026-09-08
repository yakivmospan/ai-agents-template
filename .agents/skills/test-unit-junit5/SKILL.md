---
name: test-unit-junit5
description: Use when writing unit tests for ViewModels, repositories, interactors, or other business logic classes in a JUnit5 (Jupiter) project — testing coroutine flows, state emissions, error handling, or mocking dependencies with mockk. Check specs/02-tech.md first: if this project actually uses JUnit4, use test-unit-junit4 instead, not this one. Do NOT use for UI/Compose rendering tests — those test the render tree, not isolated business logic, and need different tooling.
---

# Test Unit — JUnit5

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
| **Set and reset dispatcher** | Always `Dispatchers.setMain` in `@BeforeEach`, `Dispatchers.resetMain` in `@AfterEach` |
| **Given/When/Then comments** | In every test body |
| **When/then naming** | No camelCase, Kotlin backtick names, keep them concise |
| **Never run tests** | In agent mode — propose to validate, run, then proceed |
| **Full API surface coverage** | For classes with multiple public entry points that share underlying logic (e.g. `execute()` and `executionFlow()`), every behaviour — happy path, error, edge case — must be verified through each public entry point explicitly |
| **Orchestration, not just invocation** | When a method coordinates multiple dependencies, verify it as a whole: call order (`coVerifyOrder`), *actual* data flowing between calls (not `any()`), full state-transition sequence (not just the end value), all side effects of one call asserted together in one test, and one test per failure source showing *that* failure surfaces correctly |

---

## Tech Stack

This skill assumes JUnit5, `kotlinx-coroutines-test`, `mockk`, and robolectric — confirm against
`specs/02-tech.md`, which is the actual source of truth for this project's stack. If the framework
there is JUnit4, use `test-unit-junit4` instead; the mechanics differ (annotations, dispatcher
setup) even though the principles below don't.

---

## Template

Robolectric under JUnit5 needs its Jupiter extension registered on the class — the exact
annotation/extension class name has changed across Robolectric versions, so verify it against
whatever version is actually in `specs/02-tech.md` rather than trusting this literally; the shape
is right even if the exact name has moved on. Drop it entirely for a test class that doesn't need
Robolectric.

```kotlin
@ExtendWith(RobolectricExtension::class) // verify this class name against your Robolectric version
@OptIn(ExperimentalCoroutinesApi::class)
class ExampleTemplateTest {
    
    private val testDispatcher = StandardTestDispatcher()
    private val testScope = TestScope(testDispatcher)

    // Mocked dependencies/constants/variables go here
    
    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        // Initialize mocked dependencies/variables here
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
        clearAllMocks()
        // Any additional clean ups
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