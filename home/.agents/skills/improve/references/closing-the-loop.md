# Follow-through

## Reconcile

Read the index and relevant plans. Check evidence before changing status:

- DONE: check relevant inexpensive acceptance criteria against current code.
- TODO: compare the recorded baseline with committed and uncommitted code;
  refresh stale context or reject findings already fixed independently.
- BLOCKED: investigate the reason and update the plan when it can be resolved.
- IN PROGRESS: inspect available work and report uncertainty; do not assume an
  abandoned executor completed it.

Retain the record of finished and rejected plans. Report what is executable now.

## Execute a plan

An explicit request to execute a plan authorizes implementation within that
plan's scope. Read it, verify dependencies and drift, then implement and check
the result. Respect authorization for commits and external actions separately.

If a separate executor is explicitly requested and supported, use the available
Codex agent tools and an isolated worktree where appropriate. Do not assume a
Claude `Explore` or `general-purpose` agent, `isolation: worktree` parameter, or
Claude model names. Honor any model the user actually selected.

Provide the executor with the complete plan, applicable instructions, scope,
baseline, and verification expectations. Do not assume it can read uncommitted
plan files in a new worktree. Independently inspect the diff and check the
acceptance criteria before accepting its work. Report substantive deviations.

When delegation is unavailable, carry out authorized implementation directly
unless a separate executor is itself a requirement; in that case explain the
limitation and provide the handoff. Do not spawn an agent merely because an
ordinary planning task is large.

Update the index after verified completion or a real blocking condition. Keep
unrelated changes intact. Present the result and checks without automatically
merging, pushing, or deploying.

## Publish issues

Create issues only when explicitly requested, including `--issues`. Verify the
repository and access, check for existing equivalent issues, and use the
available GitHub connector or CLI. Read credentials through the tool's supported
authentication; never include their values in a plan or output.

Prepare concrete titles and bodies first. For the CLI, use `--body-file` to
preserve literal text and newlines. Confirm publication scope if it is unclear
or the prepared issue exposes sensitive findings to an audience the user did
not authorize. Do not ask again for a routine publication already authorized.

Record returned issue URLs in the plan and index. If publication is unavailable,
keep the local plans and report that limitation without marking issues created.
