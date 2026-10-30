# Handoff plan requirements

Use these fields when they help a fresh executor carry out the actual task.
Do not copy irrelevant sections or invent commands to fill the structure.

## Identity and state

Give the plan a numbered action title, priority, effort, risk, category,
dependencies, and status. Record the revision and uncommitted changes on which
it was based, or explicitly note that the workspace has no Git repository.

The drift check must include committed and uncommitted changes in relevant
paths. Comparing the recorded revision to the current working tree with
`git diff <recorded-revision> -- <paths>` covers tracked changes; also inspect
`git status --short -- <paths>` for untracked files. Compare cited symbols and
short excerpts with live code. Explain already-present dirty changes so they
are not misidentified as new drift. Without Git, compare the recorded file
contents and symbols directly.

## Context and scope

Describe the problem, expected observable result, and why it matters. Name the
relevant files and symbols, current behavior, local conventions, and documented
constraints. Include enough facts to work without prior conversations.

List the intended changes, meaningful exclusions, and dependencies on other
plans. Identify doc changes required by any behavior change.

## Steps and verification

Give small steps with exact files or symbols. Each step should have an
observable check and expected outcome. Derive commands from the repository and
record the working directory, prerequisites, and whether they have been run.
Do not present an unexecuted command as verified.

Describe regression coverage that protects behavior. Prefer existing tooling;
do not prescribe a new testing stack for a small reversible change. Include
manual checks where they are the appropriate verification.

## Completion and stop conditions

State done criteria, expected changed paths, and relevant check results.
Stop conditions should identify consequential drift, a false key assumption,
missing authorization, or a required change outside the agreed scope. They
should not block routine implementation choices.

If commits, publication, or deployment are needed, state their authorization
separately; writing a plan does not grant it.

## Index

Maintain a concise index with plan link, priority, dependencies, and status:
TODO, IN PROGRESS, DONE, BLOCKED with reason, or REJECTED with reason. Keep the
order consistent with dependencies. An existing plan is updated rather than
duplicated when its approach remains the same.
