---
name: karpathy-guidelines
description: Write, review, or refactor code with focused changes, explicit assumptions, simple designs, and verifiable success criteria.
license: MIT
---

# Karpathy Guidelines

Adapted from the user's Claude skill of the same name.

## Think before coding

Read relevant instructions and existing implementations. State assumptions that
affect behavior. Resolve routine ambiguity from the repository; ask only when a
choice materially changes scope or correctness. Point out a simpler approach
when it would better meet the request.

## Keep the solution small

Implement the requested behavior without speculative features, abstractions,
configuration, or fallbacks. Reuse existing project patterns. Prefer the smaller
clear implementation when it has the same observable behavior.

## Make focused changes

Match local style. Avoid adjacent formatting and unrelated refactors. Remove only
the code your change makes unused. Every changed line should support the task.
Preserve unrelated work already present in the working tree.

## Verify the goal

Turn the request into an observable result: reproduce a bug and verify the fix;
check changed behavior for a feature; compare behavior before and after a
refactor. Use the project's existing checks and add regression coverage when it
meaningfully protects the change. Update docs made inaccurate by the change.

Before finishing, inspect the diff and report the result, checks actually run,
and any material uncertainty. Do not claim a check passed without running it.
