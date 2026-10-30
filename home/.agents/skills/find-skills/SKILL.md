---
name: find-skills
description: Discover or install reusable agent skills when the user asks to find a skill, extend Codex capabilities, or locate a workflow they can reuse.
---

# Find Skills

Adapted from the user's Claude skill for Codex discovery and installation.

Identify the concrete capability and check the available skill catalog first.
Do not install a duplicate of an existing suitable skill. A general how-to or
implementation request is not by itself a request to install more capabilities.

For curated Codex skills or a named GitHub skill, use the built-in
`skill-installer` when available and follow its instructions. For external
services, inspect connected tools and use plugin discovery when it is available
and would address the actual integration need.

If another source is needed, search for the specific workflow. Read the skill
and relevant scripts before recommending or installing it. Check its provenance,
maintenance, dependencies, permissions, and compatibility with the actual Codex
environment. Popularity alone is not a quality or compatibility check.

Present a short selection with a source link, purpose, important dependencies,
and the proposed installation scope. If the user already requested installation
of an identified skill, carry it out within that scope without asking again;
respect any required filesystem or network approval.

Use the discovery locations supported by the current Codex documentation. For
this setup, user skills are in `~/.agents/skills/`; repository skills are in
`.agents/skills/`. Do not copy Claude tool names or unsupported frontmatter into
the installed skill. Validate its structure and reference paths.

If no suitable skill exists, state that and describe the narrow reusable
workflow worth creating. Do not install an unrelated package as a substitute.
