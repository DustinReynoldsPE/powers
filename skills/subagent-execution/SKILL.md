---
name: subagent-execution
description: Execute implementation plans by dispatching a fresh subagent per task with two-stage review. Use when running create-feature with --subagent flag, or when a plan has 4+ independent tasks.
---

# Subagent-Driven Execution

**Identity:** Executes a plan by dispatching one subagent per task, each followed by two-stage review (spec compliance → code quality). Use for plans with 4+ mostly-independent tasks. Do not use for tightly-coupled tasks or small plans (overhead isn't worth it).

## Input Required

A numbered plan with per-task: description, file paths, acceptance criteria.

## Process

For each task, in dependency order:

**Step 1 — Dispatch implementer**
```
Agent prompt: "Implement task N: <full task text>. Files: <paths>. Criteria: <criteria>. Context: <what prior tasks completed>."
```
Pass full task text — subagents cannot read the plan file.

**Step 2 — Spec compliance review**
```
Agent prompt: "Verify the implementation matches the spec. Read the actual code — do not trust the implementer's report. Spec: <task text>. Implementer claims: <report>."
```
If issues found: implementer fixes, reviewer re-checks. Repeat until approved.

**Step 3 — Code quality review**
```
Agent prompt: "Review code quality for: <files changed>. Check: correctness, simplicity, consistency with existing patterns, no unneeded scope."
```
If issues found: implementer fixes, re-review.

**Step 4 — Record completion**
Note completed task before moving to next.

## Red Flags

- Never dispatch multiple implementers in parallel (file conflicts)
- Never skip either review stage
- Never let the implementer self-review in place of formal review
- Never proceed to next task with open review issues

## Exit Protocol

After all tasks complete, hand back to `create-feature` Phase 6 (Test).
