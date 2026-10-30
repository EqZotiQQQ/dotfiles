# Working agreements

## Scope and communication

- Match the user's language. Keep explanations direct and concise.
- State material assumptions. Resolve routine choices from the repository and
  existing instructions; ask when missing information would change the result.
- For multi-step work, state a short plan and observable success criteria.
- Carry authorized work through implementation, relevant verification, and docs.
  Do not repeatedly ask for permission already given.

## Code

- Write simple, direct code with minimal cognitive load.
- Implement only the requested behavior. Avoid speculative abstractions,
  configurability, dependencies, and unrelated cleanup.
- Do not add fallback behavior unless the user asks for it. Do not hide a failure
  by silently substituting data, switching implementations, or swallowing errors.
- Match the style of the code being changed. Do not restyle other modules.
- Remove imports, variables, and functions made unused by your change. Mention
  unrelated dead code when relevant; do not delete it without task justification.
- Comments must be short, plain English and explain non-obvious intent.
- Read repository instructions, package manifests, and nearby code before edits.
  Use the project's existing tools and verification commands.
- Investigate the cause of a bug before fixing it. Verify the reported behavior
  with a focused reproduction and an appropriate regression check.
- Scale verification to the change. Do not create tests that merely mirror the
  implementation or add test infrastructure for a small documentation edit.
- Preserve unrelated user changes. Review the final diff for accidental edits.

## Documentation

- If a code change makes documentation inaccurate, update the affected docs in
  the same task, including commands, configuration, examples, and API contracts.
- Read the existing README, relevant docs, and decision records before writing.
  Keep established terminology and document language unless asked to change it.
- Write for the intended reader. Lead with what they need to do or understand;
  include prerequisites and copyable examples when useful.
- Derive commands, paths, flags, and defaults from the actual code and config.
  Distinguish verified behavior, proposals, and unresolved questions.
- Prefer updating the existing source of truth and linking to it over creating
  duplicate guides. Do not add documents with no concrete reader or purpose.
- Verify links and examples where feasible. Report checks that could not run.
- Keep secrets and private data out of examples, logs, findings, and reports.

## React projects using RTK Query

When the project uses RTK Query, use its hooks for server data instead of
`useEffect` plus `fetch` or `createAsyncThunk`. Extend the existing API slice with
`injectEndpoints`. Follow the project's generated hook names, such as
`useGetXQuery` and `useCreateXMutation`; use `src/services/api.ts` when that is the
existing API entry point. Do not introduce RTK Query into unrelated stacks.

## Reusable workflows

Skills live in `~/.agents/skills/`. Use the relevant skill when its description
matches the task; read its `SKILL.md` before following its workflow.

- `karpathy-guidelines`: focused implementation and code review.
- `systematic-debugging`: diagnosis of bugs, failed checks, and regressions.
- `documentation`: README, API docs, architecture docs, runbooks, and onboarding.
- `improve`: an explicit codebase audit or a handoff plan; ordinary fixes should
  not become an audit.
- `grill-me`: an explicitly requested interview about a plan or design.
- `find-skills`: discovery or installation of reusable agent capabilities.
