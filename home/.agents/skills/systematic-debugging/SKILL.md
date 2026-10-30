---
name: systematic-debugging
description: Diagnose bugs, failing tests, build failures, regressions, or unexpected behavior by gathering evidence and testing a specific root-cause hypothesis before changing code.
---

# Systematic Debugging

Adapted from the user's Claude skill. Investigate the cause before adding fixes.

## Establish the failure

- Read the complete relevant error and trace. Record the command, inputs,
  environment, and expected versus actual behavior.
- Reproduce with the smallest useful case. If it is intermittent, gather evidence
  about the conditions rather than changing several things at once.
- Inspect recent changes and compare a working case with the failing one.
- For a multi-component failure, inspect the boundary where behavior diverges:
  inputs, outputs, configuration, ownership, timing, and state. Use targeted
  instrumentation without exposing credentials or private payloads.
- Trace the invalid value or unexpected state back to its origin. A stack frame
  where the failure surfaces may not be where it begins.

## Test a hypothesis

State a specific cause and the evidence for it. Choose the smallest experiment
that distinguishes it from alternatives. Change one relevant variable at a time.
If the experiment disproves the hypothesis, update it using the new evidence;
do not pile speculative fixes onto the failed attempt.

## Fix and verify

Use a focused reproduction or regression test that exposes the original bug.
Make the smallest change that addresses the confirmed cause, match local style,
and run the reproduction again plus relevant existing checks. Update docs if the
fix changes a documented contract. Remove temporary instrumentation when done.

Do not introduce silent fallback behavior or automatic retries unless requested.
An external or environmental cause is a valid conclusion when supported by
evidence; explain the boundary and the remaining limitation honestly.

If repeated attempts fail, revisit the model of the system and gather different
evidence. Do not infer that the architecture is wrong solely from an attempt
count. Ask the user when progress requires missing access, product intent, or a
broader change beyond the authorized scope.

Report the cause, the change, the checks and their actual results, and remaining
uncertainty. This workflow requires no Claude tools or companion skills.
