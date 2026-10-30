# Audit playbook

Apply only categories relevant to the request and repository. Follow documented
trade-offs; report drift between code and documentation rather than treating an
intentional decision as a defect.

- **Correctness:** invalid state, boundary conditions, swallowed errors, races,
  resource leaks, and broken input/output contracts. Trace actual callers.
- **Security:** reachable trust-boundary failures, authorization, unsafe
  interpreter inputs, exposed credentials, and unsafe production configuration.
  Never reproduce a secret value. Distinguish a confirmed flaw from a hypothesis.
- **Performance:** demonstrated repeated work, N+1 calls, algorithmic cost,
  excessive payloads, and blocking critical paths. Prefer measurements or clear
  cost evidence over speculative caching and micro-optimizations.
- **Tests:** important behaviors without meaningful checks, weak assertions,
  flaky dependencies, and missing characterization before a risky refactor.
  Do not optimize for a coverage percentage alone.
- **Architecture and debt:** duplication with a real maintenance cost, ownership
  confusion, coupling, stale paths, or abstractions that obstruct current work.
  Do not report a personal style preference as a defect.
- **Dependencies:** relevant advisories, actual unsupported/deprecated APIs,
  manifest drift, and migration blast radius. Verify current lifecycle claims
  against authoritative sources; do not infer obsolescence from age alone.
- **Developer experience:** broken setup and checks, slow verified feedback
  loops, missing required configuration, and misleading error messages.
- **Documentation:** wrong commands, examples, defaults, or contracts; missing
  information with a concrete reader cost. Avoid proposals for docs with no user.
- **Direction:** unfinished intent, promised but absent behavior, repeated user
  friction, or a small extension strongly supported by existing architecture.
  Explain who benefits, trade-offs, uncertainty, and coarse effort separately.

## Finding format

For every finding include:

- A concrete title and category.
- Evidence at `path:line`, verified in the current working tree.
- Observable impact and affected users or operations.
- Fix effort: small, medium, or large, with a brief explanation.
- Risk of the proposed fix and what it could break.
- Confidence: confirmed, strong signal needing verification, or investigation.
- A short fix direction and a meaningful verification approach.

Prioritize dependencies that enable safe work, then high-impact findings with
strong evidence and manageable fix risk. Low-confidence items require an
investigation plan rather than a confidently prescribed fix. Record rejected
findings and the reason when maintaining an ongoing audit index.
