Ниже — версия для `AGENTS.md`. Повторяющиеся правила объединены; требование к RTK Query применяется только к проектам, где он уже используется.

```md
# Working agreements

## Scope and communication

- Match the user's language. Keep explanations direct and concise.
- State material assumptions. Resolve routine choices using the repository and existing instructions. Ask when missing information would change the result.
- For multi-step work, state a short plan and observable success criteria.
- Carry authorized work through implementation, relevant verification, and documentation. Do not ask again for permission already given.

## Code

- Write simple, direct code with minimal cognitive load. Keep simple, readable for human structure of code where it possile.
- Implement only the requested behavior. Avoid speculative abstractions, configuration, dependencies, and unrelated cleanup.
- Do not add fallback behavior unless the user asks for it. Do not hide failures by silently substituting data, switching implementations, or swallowing errors.
- Match the style of the code being changed. Do not restyle other modules.
- Remove imports, variables, and functions made unused by your change. Mention unrelated dead code when relevant, but do not delete it without task justification.
- Keep comments short, in plain English, and focused on non-obvious intent.
- Read repository instructions, package manifests, and nearby code before editing. Use the project's existing tools and verification commands.
- Investigate the cause of a bug before fixing it. Reproduce the reported behavior and run an appropriate regression check.
- Scale verification to the change. Do not add tests that merely mirror the implementation or test infrastructure for a small documentation edit.
- Preserve unrelated user changes. Review the final diff for accidental edits.
- When you we fix bugs - first of all write tests that fail, then work untill tests that failed passes. Write simple summary, how to run tests by myself + result of tests and how did you fix that.
- Suggest libraries or approaches that can simplify or impruve solution.

## Documentation

- When a code change makes documentation inaccurate, update the affected docs in the same task, including commands, configuration, examples, and API contracts.
- Read the existing README, relevant docs, and decision records before writing. Keep established terminology and document language unless asked to change them.
- Write for the intended reader. Lead with what they need to do or understand; include prerequisites and copyable examples when useful.
- Derive commands, paths, flags, and defaults from the actual code and configuration. Distinguish verified behavior, proposals, and unresolved questions.
- Update the existing source of truth and link to it instead of creating duplicate guides. Do not add documents without a concrete reader or purpose.
- Verify links and examples where feasible. Report checks that could not run.
- Keep secrets and private data out of examples, logs, findings, and reports.

## React projects using RTK Query

When the project already uses RTK Query:

- Use RTK Query hooks for server data instead of `useEffect` with `fetch` or `createAsyncThunk`.
- Extend the existing API slice with `injectEndpoints`.
- Follow the project's generated hook names, such as `useGetXQuery` and `useCreateXMutation`.
- Use `src/services/api.ts` when it is the existing API entry point.

Do not introduce RTK Query into unrelated stacks.

## Reusable workflows

Skills live in `~/.agents/skills/`. When a skill's description matches the task, read its `SKILL.md` before following its workflow.

- `karpathy-guidelines`: focused implementation and code review.
- `systematic-debugging`: diagnosis of bugs, failed checks, and regressions.
- `documentation`: README, API docs, architecture docs, runbooks, and onboarding.
- `improve`: an explicit codebase audit or handoff plan; ordinary fixes should not become an audit.
- `grill-me`: an explicitly requested interview about a plan or design.
- `find-skills`: discovery or installation of reusable agent capabilities.
```