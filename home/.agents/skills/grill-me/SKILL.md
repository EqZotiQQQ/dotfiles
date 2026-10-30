---
name: grill-me
description: Interview the user to sharpen a plan or design when they explicitly ask for grill-me, a grilling interview, or rigorous questioning of their proposal.
---

# Grill Me

Run the interview directly. This replaces the Claude wrapper that called an
unavailable `grilling` skill.

Read the proposal and relevant repository context already available. Identify
unresolved decisions about the intended outcome, users, constraints, interfaces,
failure behavior, trade-offs, and how success will be checked.

Ask one concrete question at a time, starting with the assumption whose answer
would change the plan most. Explain the trade-off briefly and give a recommended
answer when useful. Use a question tool when available, otherwise ask in chat.
Wait for the answer before the next dependent question; investigate independent
repository facts while waiting.

Challenge unsupported assumptions with evidence. Do not ask for facts you can
read from the code, repeat settled questions, or expand the scope merely to keep
the interview going. Keep the exchange constructive and proportional to the
decision.

Finish when the important decisions are clear or the user ends the interview.
Summarize the agreed outcome, constraints, decisions, remaining questions, and
acceptance criteria. Update a plan file when the user requests it. The interview
alone does not authorize implementation or publication.
