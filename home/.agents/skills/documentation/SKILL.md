---
name: documentation
description: Write or maintain technical project documentation such as READMEs, API references, architecture decisions, runbooks, and onboarding guides, including updates required by code changes.
---

# Technical Documentation

Adapted from the documentation skill in the user's Claude engineering plugin.
Use for repository documentation; cloud document editing and Word/PDF formatting
require their own available tools and workflows.

## Ground the document

Identify the intended reader and what they need to accomplish. Read the existing
document, relevant code and configuration, and applicable decision records.
Resolve facts from the repository before asking the user. Preserve established
terminology, document language, and local organization unless asked to change it.

Find the existing source of truth and update it. Link to maintained information
instead of copying it into another guide. Scale the document to its actual use;
do not add empty sections, placeholder promises, or an unsolicited docs tree.

## Choose the content that helps the reader

- **README:** purpose, shortest working setup and first use, required
  configuration, and links for deeper tasks.
- **API reference:** actual signatures or endpoints, parameters, defaults,
  returned data, errors, and minimal examples. Include authentication,
  pagination, or limits only where applicable.
- **Runbook:** triggering symptoms, prerequisites, diagnosis, ordered actions,
  expected results, and recovery or rollback steps where they are meaningful.
  Mark actions that affect live systems; writing a runbook does not authorize
  executing them.
- **Architecture or decision record:** context, constraints, actual components
  and data flow, decision, trade-offs, and consequences. Distinguish a proposed
  design from an implemented one.
- **Onboarding:** verified environment setup, key concepts and directories,
  common tasks, and existing support references.

Lead with useful information. Prefer short concrete explanations and examples.
Use diagrams only when they make the system clearer. Explain prerequisites
before commands and specify the directory in which a command runs.

## Verify and deliver

Check paths, relative links, command names, flags, defaults, and API examples
against the actual project. Run safe local examples and existing documentation
checks when relevant. Do not execute destructive or production actions merely
to test a runbook. Use placeholders for secrets and personal data.

For behavior changes, check affected setup, configuration, CLI/API reference,
and examples. Keep updates focused on what became inaccurate.

Review the final diff. Report which docs changed and what was verified; identify
examples or commands that could not be exercised and why.
