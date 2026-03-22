---
name: using-powers
description: Establishes skill usage patterns at session start
---

# Powers Plugin

Structured development workflows using tk tickets.

## Start New Work

- `/create-feature` — Full feature workflow (brainstorm → worktree → plan → execute → test → finish)
- `/create-feature --subagent` — Same, but dispatches a fresh subagent per plan task with two-stage review (4+ tasks)
- `/create-bug` — Lean bug workflow (investigate → fix → test → finish)

## Resume Existing Work

- `/work-ticket <id>` — Resume any ticket from its last checkpoint

## Branch Completion

- `/finishing-branch` — Close out a branch: PR, merge, keep, or discard. Removes worktree.

## Debugging

- `/investigate` — Disciplined debugging methodology: structured intake, logging-first, 3-patch rule

## Design

- `/brainstorming` — Socratic design refinement before implementation

## Principles

One ticket = one branch = one PR. Each workflow creates an isolated worktree, works on a ticket branch, and finishes with a PR or local merge.
